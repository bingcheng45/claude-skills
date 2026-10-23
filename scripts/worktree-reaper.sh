#!/usr/bin/env bash
# Removes git worktrees Claude left behind once their work is saved elsewhere.
# Dry run by default; --apply removes. Built for a daily launchd job.
set -u

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin${PATH:+:$PATH}"
export GIT_TERMINAL_PROMPT=0

ROOT="${WORKTREE_REAPER_ROOT:-$HOME/ai_projects}"
LOG="${WORKTREE_REAPER_LOG:-$HOME/Library/Logs/worktree-reaper.log}"
IDLE_DAYS="${WORKTREE_IDLE_DAYS:-7}"
MERGED_IDLE_DAYS="${WORKTREE_MERGED_IDLE_DAYS:-1}"
APP_MANAGED_RE='^[a-z]+-[a-z]+-[0-9a-f]{6}$'
LOCK_GRACE_SECS=60
MODE=dry-run

usage() {
	cat <<EOF
Usage: worktree-reaper.sh [--apply] [--help] [extra-repo-path ...]

Scans every main checkout under \$WORKTREE_REAPER_ROOT (default ~/ai_projects),
~/.claude/skills, and any repo paths given, then keeps or removes each linked
worktree by an ordered rule table. Dry run unless --apply is given.

Environment:
  WORKTREE_REAPER_ROOT        repo root to scan (default: \$HOME/ai_projects)
  WORKTREE_REAPER_LOG         TSV log (default: ~/Library/Logs/worktree-reaper.log)
  WORKTREE_IDLE_DAYS          idle days before an unreviewed worktree goes (default 7)
  WORKTREE_MERGED_IDLE_DAYS   idle days before a merged/closed-PR worktree goes (default 1)
EOF
}

EXTRA_REPOS=()
for arg in "$@"; do
	case "$arg" in
		--apply) MODE=apply ;;
		-h|--help) usage; exit 0 ;;
		-*) echo "unknown option: $arg" >&2; usage >&2; exit 2 ;;
		*) EXTRA_REPOS+=("$arg") ;;
	esac
done

mkdir -p "$(dirname "$LOG")"
LOCK="$LOG.lock"
TMP=$(mktemp -d "${TMPDIR:-/tmp}/worktree-reaper.XXXXXX") || exit 1
OWN_LOCK=no
cleanup() {
	rm -rf "$TMP"
	[ "$OWN_LOCK" = yes ] && rm -rf "$LOCK"
}
trap cleanup EXIT
trap 'exit 130' INT TERM

acquire_lock() {
	if mkdir "$LOCK" 2>/dev/null; then
		echo $$ >"$LOCK/pid"; OWN_LOCK=yes; return 0
	fi
	local pid age
	pid=$(cat "$LOCK/pid" 2>/dev/null)
	if [ -n "$pid" ]; then
		kill -0 "$pid" 2>/dev/null && return 1
	else
		# A holder that has made the dir but not yet written its pid looks stale.
		age=$(( $(date +%s) - $(stat -f %m "$LOCK" 2>/dev/null || echo 0) ))
		[ "$age" -lt "$LOCK_GRACE_SECS" ] && return 1
	fi
	rm -rf "$LOCK"
	mkdir "$LOCK" 2>/dev/null || return 1
	echo $$ >"$LOCK/pid"; OWN_LOCK=yes
}

now_iso() { date +%Y-%m-%dT%H:%M:%S%z; }

log_tsv() {
	local IFS=$'\t'
	printf '%s\n' "$(now_iso)	$MODE	$*" >>"$LOG"
}

human_kb() {
	awk -v k="$1" 'BEGIN {
		if (k >= 1048576) printf "%.1fG", k / 1048576
		else if (k >= 1024) printf "%.0fM", k / 1024
		else printf "%dK", k }'
}

if ! acquire_lock; then
	echo "another worktree-reaper run holds $LOCK; exiting" >&2
	exit 0
fi

NOW=$(date +%s)
CWDS="$TMP/cwds"
snapshot_cwds() { lsof -d cwd -Fn 2>/dev/null | sed -n 's/^n//p' >"$CWDS"; }

path_in_use() {
	local p phys
	phys=$(cd "$1" 2>/dev/null && pwd -P)
	for p in "$1" "$phys"; do
		[ -z "$p" ] && continue
		awk -v p="$p" '$0 == p || substr($0, 1, length(p) + 1) == p "/" { found = 1; exit } END { exit !found }' "$CWDS" && return 0
	done
	return 1
}

# One line per main checkout, deduped by git common dir.
discover_repos() {
	local cand common main seen=""
	{
		for cand in "$ROOT"/*/; do
			[ -d "${cand}.git" ] && printf '%s\n' "${cand%/}"
		done
		[ -d "$HOME/.claude/skills" ] && printf '%s\n' "$HOME/.claude/skills"
		for cand in ${EXTRA_REPOS[@]+"${EXTRA_REPOS[@]}"}; do printf '%s\n' "$cand"; done
	} | while IFS= read -r cand; do
		common=$(git -C "$cand" rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || continue
		case "$seen" in *"|$common|"*) continue ;; esac
		seen="$seen|$common|"
		main=$(git -C "$cand" worktree list --porcelain 2>/dev/null | sed -n '1s/^worktree //p')
		[ -n "$main" ] && printf '%s\n' "$main"
	done
}

resolve_main_ref() {
	local r
	for r in origin/main origin/master; do
		git -C "$1" rev-parse --verify -q "refs/remotes/$r" >/dev/null && { echo "$r"; return; }
	done
	r=$(git -C "$1" symbolic-ref -q --short refs/remotes/origin/HEAD 2>/dev/null)
	[ -n "$r" ] && { echo "$r"; return; }
	for r in main master; do
		git -C "$1" rev-parse --verify -q "refs/heads/$r" >/dev/null && { echo "$r"; return; }
	done
}

# Per-repo context, set by scan_repo.
REPO="" MAIN_REF="" PRS_JSON="" PRS_OK=no BODY_FILE=""

# The record. gather_record fills these; decide reads them.
R_PATH="" R_BRANCH="" R_UPSTREAM="" R_LOCKED=no R_IN_USE=no R_APP=no
R_TRACKED=0 R_UNTRACKED=0 R_UNTRACKED_NAMES="" R_IDLE=0
R_PR_STATE=none R_PR_NUM="" R_SAVED=no R_KB=0

g() { git --no-optional-locks -C "$R_PATH" "$@"; }

count_edits() {
	local porcelain
	if ! porcelain=$(g status --porcelain 2>/dev/null); then
		# Unreadable status counts as edits so the worktree is kept.
		R_TRACKED=1; R_UNTRACKED=0; R_UNTRACKED_NAMES=""; return
	fi
	R_TRACKED=$(printf '%s\n' "$porcelain" | grep -c -v -e '^??' -e '^$')
	R_UNTRACKED=$(printf '%s\n' "$porcelain" | grep -c '^??')
	R_UNTRACKED_NAMES=$(printf '%s\n' "$porcelain" | sed -n 's/^?? //p' | head -5 | paste -sd, -)
}

last_touch_epoch() {
	local files_max head_ct logs_mt gitdir
	files_max=$( (cd "$R_PATH" && git --no-optional-locks ls-files -co --exclude-standard -z 2>/dev/null \
		| xargs -0 stat -f %m 2>/dev/null) | sort -n | tail -1)
	head_ct=$(g log -1 --format=%ct HEAD 2>/dev/null)
	gitdir=$(g rev-parse --absolute-git-dir 2>/dev/null)
	logs_mt=""
	[ -n "$gitdir" ] && [ -f "$gitdir/logs/HEAD" ] && logs_mt=$(stat -f %m "$gitdir/logs/HEAD" 2>/dev/null)
	printf '%s\n' "${files_max:-0}" "${head_ct:-0}" "${logs_mt:-0}" | sort -n | tail -1
}

lookup_pr() {
	local name hit
	R_PR_STATE=none; R_PR_NUM=""
	[ "$PRS_OK" = yes ] || { R_PR_STATE=unknown; return; }
	for name in "$R_BRANCH" "${R_UPSTREAM#origin/}"; do
		[ -z "$name" ] && continue
		hit=$(jq -r --arg b "$name" \
			'map(select(.headRefName == $b)) | .[0] // empty | "\(.state)\t\(.number)"' "$PRS_JSON" 2>/dev/null)
		if [ -n "$hit" ]; then
			R_PR_STATE=${hit%%	*}; R_PR_NUM=${hit#*	}; return
		fi
	done
}

# Squash merges leave HEAD off main, so commit subjects found in main's
# messages also count as saved.
subjects_on_main() {
	local missing
	[ -n "$BODY_FILE" ] || return 1
	[ -s "$BODY_FILE" ] || git -C "$REPO" log "$MAIN_REF" --format=%B >"$BODY_FILE" 2>/dev/null
	missing=$(g log --format=%s "$MAIN_REF..HEAD" 2>/dev/null | while IFS= read -r s; do
		grep -qF -- "$s" "$BODY_FILE" || { echo x; break; }
	done)
	[ -z "$missing" ]
}

is_saved() {
	[ "$R_PR_STATE" = MERGED ] && return 0
	[ -n "$(g branch -r --contains HEAD 2>/dev/null)" ] && return 0
	[ -n "$MAIN_REF" ] || return 1
	g merge-base --is-ancestor HEAD "$MAIN_REF" 2>/dev/null && return 0
	[ "$(g rev-list --count "$MAIN_REF..HEAD" 2>/dev/null)" = 0 ] && return 0
	subjects_on_main
}

gather_record() {
	R_PATH=$1; R_LOCKED=$2
	R_BRANCH=$(g symbolic-ref --quiet --short HEAD 2>/dev/null)
	R_UPSTREAM=""
	[ -n "$R_BRANCH" ] && R_UPSTREAM=$(g rev-parse --abbrev-ref "$R_BRANCH@{upstream}" 2>/dev/null)
	R_APP=no
	case "$R_PATH" in
		*/.claude/worktrees/*) [[ "$(basename "$R_PATH")" =~ $APP_MANAGED_RE ]] && R_APP=yes ;;
	esac
	R_IN_USE=no; path_in_use "$R_PATH" && R_IN_USE=yes
	count_edits
	R_IDLE=$(( (NOW - $(last_touch_epoch)) / 86400 ))
	lookup_pr
	R_SAVED=no; is_saved && R_SAVED=yes
	R_KB=$(du -sk "$R_PATH" 2>/dev/null | awk '{print $1}')
	R_KB=${R_KB:-0}
}

# Ordered rule table: first match wins.
decide() {
	if   [ "$R_APP" = yes ];          then V_ACTION=keep;   V_REASON=app-managed
	elif [ "$R_LOCKED" = yes ];       then V_ACTION=keep;   V_REASON=locked
	elif [ "$R_IN_USE" = yes ];       then V_ACTION=keep;   V_REASON=in-use
	elif [ "$R_TRACKED" -gt 0 ];      then V_ACTION=keep;   V_REASON=uncommitted-edits
	elif [ "$R_PR_STATE" = OPEN ];    then V_ACTION=keep;   V_REASON=open-pr
	elif [ "$R_PR_STATE" = unknown ]; then V_ACTION=keep;   V_REASON=pr-unknown
	elif [ "$R_SAVED" = no ];         then V_ACTION=keep;   V_REASON=unsaved-commits
	elif { [ "$R_PR_STATE" = MERGED ] || [ "$R_PR_STATE" = CLOSED ]; } && [ "$R_IDLE" -ge "$MERGED_IDLE_DAYS" ]
	                                  then V_ACTION=remove; V_REASON="pr-$(printf '%s' "$R_PR_STATE" | tr '[:upper:]' '[:lower:]')"
	elif [ "$R_IDLE" -ge "$IDLE_DAYS" ]; then V_ACTION=remove; V_REASON="idle-${R_IDLE}d"
	else                                   V_ACTION=keep;   V_REASON=recent
	fi
}

# rm -rf only a leftover linked worktree dir, never a main checkout or a root.
safe_to_rm() {
	local p=$1
	[ "$p" = "$REPO" ] && return 1
	[ -d "$p/.git" ] && return 1
	case "$p" in /|"$HOME"|"$HOME/"|"$ROOT"|"$ROOT/") return 1 ;; esac
	return 0
}

remove_worktree() {
	git -C "$REPO" worktree remove --force "$R_PATH" 2>>"$TMP/errors"
	[ -e "$R_PATH" ] && safe_to_rm "$R_PATH" && rm -rf "$R_PATH"
	git -C "$REPO" worktree prune 2>/dev/null
	[ ! -e "$R_PATH" ]
}

act() {
	if [ "$V_ACTION" = remove ]; then
		if [ "$MODE" = dry-run ]; then
			V_ACTION=would-remove
		else
			snapshot_cwds
			R_IN_USE=no; path_in_use "$R_PATH" && R_IN_USE=yes
			count_edits
			decide
			if [ "$V_ACTION" = remove ] && ! remove_worktree; then V_ACTION=remove-failed; fi
		fi
	fi
	local pr="$R_PR_STATE${R_PR_NUM:+#$R_PR_NUM}" size
	size=$(human_kb "$R_KB")
	log_tsv "$V_ACTION" "$V_REASON" "$size" "$R_IDLE" "$pr" "$(basename "$REPO")" "$R_PATH" "$R_UNTRACKED_NAMES"
	printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
		"$V_ACTION" "$V_REASON" "$R_KB" "$size" "${R_IDLE}d" "$pr" "$R_UNTRACKED" "$R_PATH" >>"$TMP/rows"
}

scan_repo() {
	REPO=$1
	local n=$2 wt locked
	# Prune mutates admin state, so dry runs skip it; missing paths are skipped below anyway.
	[ "$MODE" = apply ] && git -C "$REPO" worktree prune 2>/dev/null
	git -C "$REPO" worktree list --porcelain 2>/dev/null | awk '
		/^worktree / { if (p != "") print p "\t" l; p = substr($0, 10); l = "no" }
		/^locked/    { l = "yes" }
		END          { if (p != "") print p "\t" l }' | tail -n +2 >"$TMP/wts.$n"
	[ -s "$TMP/wts.$n" ] || return 0

	git -C "$REPO" fetch origin --quiet </dev/null >/dev/null 2>&1
	MAIN_REF=$(resolve_main_ref "$REPO")
	BODY_FILE=""
	[ -n "$MAIN_REF" ] && BODY_FILE="$TMP/body.$n"
	PRS_JSON="$TMP/prs.$n.json"
	if ! git -C "$REPO" remote get-url origin >/dev/null 2>&1; then
		echo '[]' >"$PRS_JSON"; PRS_OK=yes
	elif (cd "$REPO" && gh pr list --state all --limit 500 --json number,state,headRefName) \
		</dev/null >"$PRS_JSON" 2>/dev/null; then PRS_OK=yes; else PRS_OK=no; fi

	while IFS=$'\t' read -r wt locked <&3; do
		[ -d "$wt" ] || continue
		gather_record "$wt" "$locked"
		decide
		act
	done 3<"$TMP/wts.$n"
}

print_report() {
	: >>"$TMP/rows"
	{
		printf 'ACTION\tREASON\tSIZE\tIDLE\tPR\tUNTRACKED\tPATH\n'
		awk -F'\t' '{ rank = ($1 == "keep") ? 1 : 0; print rank "\t" $0 }' "$TMP/rows" \
			| sort -t$'\t' -k1,1n -k2,2 -k9,9 | cut -f2- \
			| awk -F'\t' -v OFS='\t' '{ print $1, $2, $4, $5, $6, $7, $8 }'
	} | column -t -s$'\t'
	SUMMARY=$(awk -F'\t' -v mode="$MODE" '
		{ count[$1]++ }
		$1 == "remove" || $1 == "would-remove" { kb += $3 }
		END {
			s = ""
			for (a in count) s = s (s == "" ? "" : ", ") a "=" count[a]
			if (s == "") s = "no worktrees"
			label = (mode == "apply") ? "freed" : "freeable"
			if (kb >= 1048576) sz = sprintf("%.1fG", kb / 1048576); else sz = sprintf("%.0fM", kb / 1024)
			printf "%s; %s %s", s, label, sz
		}' "$TMP/rows")
	echo
	echo "worktree-reaper $MODE: $SUMMARY"
}

log_tsv run-start "root=$ROOT idle=$IDLE_DAYS merged_idle=$MERGED_IDLE_DAYS"
snapshot_cwds
n=0
discover_repos >"$TMP/repos"
while IFS= read -r repo <&4; do
	n=$((n + 1))
	scan_repo "$repo" "$n"
done 4<"$TMP/repos"
print_report
log_tsv run-end "$SUMMARY"
