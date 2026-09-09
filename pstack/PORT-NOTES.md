# pstack, ported to Claude Code

Upstream: <https://github.com/cursor/plugins/tree/main/pstack> (MIT, Lauren Tan). Ported at upstream
version **0.14.5**. Upstream is a Cursor plugin; this tree is the same content with Cursor-specific
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
| `grok-4.6-fast-xhigh` | `sonnet` | fast code delegate, explorers, swarm workers |
| `gpt-5.6-sol-max` | `opus` | debugging, perf, hillclimb, tooling review |
| `claude-fable-5-thinking-max` | `fable` | judgment and prose |
| `claude-opus-5-thinking-xhigh` | `opus` | hardest tasks |

Four-model review panels (`how critics`, `arena runners`, `architect runners`,
`interrogate reviewers`) collapse to three: `fable, opus, sonnet`. **The cross-family diversity
upstream relies on is gone** — panels here differ by tier, not by vendor, so they correlate more than
upstream's do. Weigh a unanimous panel accordingly. Override any role in `~/.claude/pstack-models.md`
or by running `/setup-pstack`.

### Dropped

- `make-bot-ui` — built entirely on Cursor routines, `update_state`, and `api2.cursor.sh` webhooks.
  No Claude Code equivalent.
- `automations/benny` — Cursor automation definition, not a skill.

### Untouched

`skills/poteto-mode/scripts/` (TypeScript + bun) is upstream's own tooling and runs the same here.
`CURSOR_AUTOMATION_ID` parsing in `watch-pr` reads Bugbot comment metadata from GitHub, so it stays.

## Pulling upstream changes

The upstream checkout is at `~/.claude/pstack-src` (sparse, `pstack/` only).

```bash
cd ~/.claude/pstack-src && git pull
git -C ~/.claude/pstack-src diff HEAD@{1} -- pstack   # see what moved
```

Re-apply the table above to anything new. The rewrites were textual, so a fresh copy plus the same
substitutions reproduces this tree.
