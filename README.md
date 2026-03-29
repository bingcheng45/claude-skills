# Claude Skills

A personal collection of Claude Code skills and OMC (oh-my-claudecode) workflows — versioned here to stay in sync across devices.

## Overview

This repo is the single source of truth for all Claude skills on all machines.

```
clone → ~/.claude/skills
```

Changes made locally on any device should be committed and pushed here. Pull on other devices to sync.

---

## Folder Structure

```
claude-skills/
├── skills/                    # Personal & custom Claude skills
│   ├── omc-reference/         # OMC agent catalog reference
│   └── skill-creator/         # Create, test, and optimize new skills
│
├── omc/                       # oh-my-claudecode built-in skills
│   ├── AGENTS.md              # OMC agent definitions
│   ├── autopilot/             # Full autonomous execution
│   ├── ralph/                 # Persistent loop until done
│   ├── ultrawork/             # High-throughput parallel execution
│   ├── ralplan/               # Consensus planning workflow
│   ├── deep-interview/        # Socratic requirements gathering
│   ├── team/                  # Multi-agent team orchestration
│   ├── ultraqa/               # QA cycle: test → fix → repeat
│   ├── ai-slop-cleaner/       # Clean AI-generated code
│   ├── project-session-manager/ # Worktree + tmux dev environments
│   └── ...                    # All other OMC skills
│
└── README.md
```

Each skill lives in its own folder with at minimum a `SKILL.md` file:

```yaml
---
name: skill-name
description: When and why Claude should use this skill
---
```

---

## Installation

Clone directly into your Claude skills directory:

```bash
git clone https://github.com/bingcheng45/claude-skills.git ~/.claude/skills
```

Then restart Claude Code — skills are loaded at startup.

> **Note:** OMC skills in `omc/` are managed by oh-my-claudecode. The copies here are for versioning and reference. To install OMC itself, say `"setup omc"` inside Claude Code.

---

## Syncing Across Devices

```bash
# Pull latest skills on a new/other device
cd ~/.claude/skills && git pull

# After adding or modifying a skill locally
cd ~/.claude/skills
git add .
git commit -m "feat: add/update <skill-name>"
git push
```

---

## Skills Reference

### `skills/` — Personal Skills

| Skill | Description | Trigger |
|-------|-------------|---------|
| [skill-creator](./skills/skill-creator/) | Create, test, benchmark, and optimize new Claude skills | "create a skill for X", "make a skill that does X" |
| [omc-reference](./skills/omc-reference/) | OMC agent catalog and tools reference | Auto-loads when orchestrating agents |

### `omc/` — OMC Built-in Skills

| Skill | Description | Trigger |
|-------|-------------|---------|
| [autopilot](./omc/autopilot/) | Full autonomous idea → working code | say `"autopilot: ..."` |
| [ralph](./omc/ralph/) | Loop until task is complete and verified | say `"ralph: ..."` |
| [ultrawork](./omc/ultrawork/) | Parallel execution for large tasks | say `"ulw: ..."` |
| [ralplan](./omc/ralplan/) | Consensus planning before execution | say `"ralplan: ..."` |
| [deep-interview](./omc/deep-interview/) | Socratic requirements gathering | say `"deep interview: ..."` |
| [team](./omc/team/) | Coordinated multi-agent team | `/oh-my-claudecode:team` |
| [ultraqa](./omc/ultraqa/) | QA cycle: test, verify, fix, repeat | `/oh-my-claudecode:ultraqa` |
| [ai-slop-cleaner](./omc/ai-slop-cleaner/) | Clean up AI-generated code slop | say `"deslop"` |
| [ccg](./omc/ccg/) | Claude + Codex + Gemini synthesis | say `"ccg"` |
| [deep-dive](./omc/deep-dive/) | Trace investigation + requirements | `/oh-my-claudecode:deep-dive` |
| [external-context](./omc/external-context/) | Parallel external docs/web research | `/oh-my-claudecode:external-context` |
| [visual-verdict](./omc/visual-verdict/) | Screenshot visual QA verdict | `/oh-my-claudecode:visual-verdict` |
| [writer-memory](./omc/writer-memory/) | Track characters, scenes, themes | `/oh-my-claudecode:writer-memory` |
| [project-session-manager](./omc/project-session-manager/) | Worktree + tmux dev environments | `/oh-my-claudecode:project-session-manager` |
| [omc-setup](./omc/omc-setup/) | Install or refresh OMC | say `"setup omc"` |
| [mcp-setup](./omc/mcp-setup/) | Configure MCP servers | `/oh-my-claudecode:mcp-setup` |
| [configure-notifications](./omc/configure-notifications/) | Set up Telegram/Discord/Slack alerts | `/oh-my-claudecode:configure-notifications` |
| [hud](./omc/hud/) | Configure HUD display options | `/oh-my-claudecode:hud` |
| [omc-doctor](./omc/omc-doctor/) | Diagnose OMC install issues | `/oh-my-claudecode:omc-doctor` |
| [learner](./omc/learner/) | Extract a skill from a conversation | `/oh-my-claudecode:learner` |
| [sciomc](./omc/sciomc/) | Parallel scientist agents for research | say `"deep-analyze"` |
| [trace](./omc/trace/) | Evidence-driven causal tracing | `/oh-my-claudecode:trace` |

---

## Adding New Skills

Use the `skill-creator` skill:

1. Open Claude Code in any project
2. Say: *"create a skill for [your workflow]"*
3. Claude guides you through drafting, testing, and optimizing it
4. Drop the resulting folder into `skills/`, commit, and push

---

## Resources

- [oh-my-claudecode](https://github.com/sgomez/oh-my-claudecode) — OMC plugin
- [Claude Code Docs](https://docs.anthropic.com/claude-code) — full documentation
