# pstack, ported to Claude Code

Upstream: <https://github.com/cursor/plugins/tree/main/pstack> (MIT, Lauren Tan). Ported at upstream
version **0.15.9** (upstream commit `e43c7ee`). Upstream is a Cursor plugin; this tree is the same content with Cursor-specific
paths, tools, model slugs, and sibling-plugin skills rewritten for Claude Code.

## Install shape

Lives at `~/.claude/skills/pstack/`, which Claude Code auto-loads as the `pstack@skills-dir` plugin.

```bash
claude plugin list                  # confirm pstack@skills-dir is enabled
claude plugin details pstack        # component inventory + projected token cost
claude plugin disable pstack        # turn it off
```

## What changed from upstream

| Cursor | Claude Code |
|---|---|
| `~/.cursor/rules/pstack-models.mdc` (always-applied rule) | `~/.claude/pstack-models.md` (plain file each skill reads when it delegates) |
| `.cursor/skills/`, `~/.cursor/skills/`, `~/.cursor/plugins/` | `.claude/skills/`, `~/.claude/skills/`, `~/.claude/plugins/` |
| `~/.cursor/projects/<slug>/agent-transcripts/<uuid>/<uuid>.jsonl` | `~/.claude/projects/<slug>/<uuid>.jsonl` (slug keeps its leading `-`) |
| `AskQuestion` tool | `AskUserQuestion` tool |
| `Task` tool, `subagent_type: generalPurpose` | `Agent` tool, `subagent_type: general-purpose` |
| `readonly: true` / `readonly: false` (agent mode) | no such flag; read-only is an instruction, or a read-only agent type such as `Explore` (which cannot reach MCP) |
| `/deslop` from `cursor-team-kit` | `/simplify` (built-in) |
| `control-ui` / `control-cli` from `cursor-team-kit` | `claude-in-chrome` skill / `run` skill |
| Cursor's built-in `create-skill` | `skill-creator` skill |
| Cursor's `/loop` command | `/loop` skill (built-in) |
| Cursor cloud agents | background agents (`Agent` with `run_in_background: true`, `isolation: "worktree"` when they write) |

### Model roles

Upstream defaults name four vendors. Claude Code's `Agent` tool takes `opus`, `sonnet`, `haiku`,
`fable`, so the roles were remapped by intent, not by name:

| Upstream slug | Here | Role |
|---|---|---|
| `grok-4.7-xhigh-fast` | `sonnet` | fast code delegate, explorers, swarm workers, and the `bug-fix`, `perf-issue`, `hillclimb` playbooks |
| `claude-opus-5-5-max` | `fable` | judgment, prose, and the hardest tasks |
| `gpt-5.6-sol-max` | `opus` | `reflect tooling` and the second panel seat |

Upstream renamed its slugs between 0.14.5 and 0.15.9, so map by role, never by slug text. Two role
assignments also moved upstream: `bug-fix`, `perf-issue` and `hillclimb` went from the deep debugging
model to the fast code model, and "hardest tasks" no longer splits between a judgment model and an
instruction-following model. The port follows both. To keep the old routing for debugging work, put
`bug-fix: opus` (and the same for the other two) in `~/.claude/pstack-models.md`.

Review panels (`arena runners`, `architect runners`, `interrogate reviewers`) are three seats upstream
and here: `fable, opus, sonnet`. **The cross-family diversity upstream relies on is gone**, because panels
here differ by tier, not by vendor, so they correlate more than upstream's do. Weigh a unanimous panel
accordingly. Override any role in `~/.claude/pstack-models.md` or by running `/setup-pstack`.

### Dropped

- **Reasoning budget in `setup-pstack`** (0.15.x). It rewrites the effort suffix inside a Cursor model slug
  (`claude-opus-5-5-max` to `claude-opus-5-5-medium`). The `Agent` tool takes tier aliases only and has no
  effort parameter, so there is nothing for it to act on.
- **Family-prefix model fallback** (`claude-*`, `gpt-*`, `grok-*`). Upstream seats are different vendors, so
  a rejected model falls back within its vendor. Here every seat is a Claude tier, so the rule was ported as
  its intent: fall back to the seat's default, then to the closest valid tier, and never block.

- `make-bot-ui` — built entirely on Cursor routines, `update_state`, and `api2.cursor.sh` webhooks.
  No Claude Code equivalent.
- `automations/benny` — Cursor automation definition, not a skill.

### Untouched

`skills/poteto-mode/scripts/` (TypeScript + bun) is upstream's own tooling and runs the same here.
`CURSOR_AUTOMATION_ID` parsing in `watch-pr` reads Bugbot comment metadata from GitHub, so it stays.

### Local additions

Not from upstream. A three-way merge leaves these alone. A fresh copy of upstream would delete them.

| Skill | What it does |
|---|---|
| `skills/goal-alignment/` | Restates the user's goal, the problem behind it, and the load-bearing assumptions before work starts. User-invoked. |

## Pulling upstream changes

The upstream checkout is at `~/.claude/pstack-src` (sparse, `pstack/` only).

```bash
cd ~/.claude/pstack-src && git pull
git -C ~/.claude/pstack-src diff <old>..HEAD --stat -- pstack   # size the change
```

**Do not re-copy and re-substitute.** That was this file's earlier advice, and it is wrong. The port has
contextual prose rewrites (`readonly` becoming "keep it read-only", cloud-agent wording, transcript paths) that
a substitution table cannot reproduce. A pure table left 186 lines wrong across 33 files when tested against
0.14.5. Merge instead:

1. Three-way merge each changed file with `git merge-file`, where base is the old upstream, ours is this
   tree, and theirs is the new upstream. Files this tree never edited take upstream directly.
2. For conflicts, start from the new upstream text, apply the table above, and re-apply the contextual
   rewrites by hand. Do not resolve at word level, which misaligns on repeated words.
3. Port new concepts by intent, not by text (see Dropped).
4. Sweep for leftover Cursor vocabulary: `Cursor`, `cursor-team-kit`, `.cursor`, `agent-transcripts`,
   `AskQuestion`, `generalPurpose`, `Task` as a tool name, `readonly` outside TypeScript, `alwaysApply`.
5. Check frontmatter. `name` must be kebab-case and match the directory (upstream's `name: Poteto Mode` breaks
   `/pstack:poteto-mode`), and agent files must not carry `is_background`.
6. Run `bun install && bun test` in `skills/poteto-mode/scripts/`. Never commit the `node_modules` it creates.
