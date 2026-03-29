# Claude Skills

A personal collection of Claude Code skills and OMC (oh-my-claudecode) workflows — versioned here to stay in sync across devices.

## Overview

This repo is the single source of truth for all Claude skills on all machines.

```
git clone https://github.com/bingcheng45/claude-skills.git ~/.claude/skills
```

---

## Folder Structure

```
~/.claude/skills/               ← this repo (global skills directory)
├── skill-creator/              ← loaded by Claude ✓
├── omc-reference/              ← loaded by Claude ✓
│
├── omc/                        ← reference copies of OMC built-in skills
│   ├── autopilot/              │  (loaded by OMC from its own plugin path,
│   ├── ralph/                  │   not from here — for versioning only)
│   └── ...
│
├── .gitignore
└── README.md
```

> **How Claude discovers skills:** Claude loads any folder with a `SKILL.md` directly inside `~/.claude/skills/<name>/SKILL.md`. Skills must be at the **root level** of this directory — nested subfolders won't be auto-loaded.
>
> **OMC skills** (`omc/`) are loaded by oh-my-claudecode from `~/.claude/plugins/marketplaces/omc/skills/`. The copies here are for versioning and reference only.

---

## Installation

Clone directly into your Claude skills directory:

```bash
git clone https://github.com/bingcheng45/claude-skills.git ~/.claude/skills
```

Then restart Claude Code — skills are loaded at startup.

---

## Syncing Across Devices

```bash
# Pull latest on another device
cd ~/.claude/skills && git pull

# After adding or modifying a skill locally
cd ~/.claude/skills
git add <skill-folder>
git commit -m "feat: add/update <skill-name>"
git push
```

---

## Personal Skills

These live at the root and are auto-loaded by Claude globally:

| Skill | Description | Trigger |
|-------|-------------|---------|
| [skill-creator](./skill-creator/) | Create, test, benchmark, and optimize new Claude skills | "create a skill for X", "make a skill that does X" |
| [omc-reference](./omc-reference/) | OMC agent catalog and tools reference | Auto-loads when orchestrating agents |
| [explain](./explain/) | Explains any concept using Feynman first-principles style — clear, analogy-driven, no jargon | "explain X", "ELI5 X", "/explain X" |
| [learning-goal](./learning-goal/) | Structured goal-setting using MCII — visualize outcomes, anticipate obstacles, build if-then plans | "set a learning goal", "help me plan what to learn" |
| [learning-opportunities](./learning-opportunities/) | Offers learning exercises after architectural work to deepen understanding of design choices | Auto-triggers after features/refactors, "help me understand this" |

---

## OMC Built-in Skills (`omc/`)

Reference copies of skills bundled with oh-my-claudecode. Invoke these via keyword or slash command inside Claude Code:

| Skill | Description | Trigger |
|-------|-------------|---------|
| [autopilot](./omc/autopilot/) | Full autonomous idea → working code | say `"autopilot: ..."` |
| [ralph](./omc/ralph/) | Loop until task is complete and verified | say `"ralph: ..."` |
| [ultrawork](./omc/ultrawork/) | Parallel execution for large tasks | say `"ulw: ..."` |
| [ralplan](./omc/ralplan/) | Consensus planning before execution | say `"ralplan: ..."` |
| [deep-interview](./omc/deep-interview/) | Socratic requirements gathering | say `"deep interview: ..."` |
| [team](./omc/team/) | Coordinated multi-agent team | `/oh-my-claudecode:team` |
| [ultraqa](./omc/ultraqa/) | QA cycle: test, verify, fix, repeat | `/oh-my-claudecode:ultraqa` |
| [ai-slop-cleaner](./omc/ai-slop-cleaner/) | Clean up AI-generated code | say `"deslop"` |
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
4. Drop the resulting folder into `~/.claude/skills/` (repo root), commit, and push

---

## Resources

- [oh-my-claudecode](https://github.com/sgomez/oh-my-claudecode) — OMC plugin
- [Claude Code Docs](https://docs.anthropic.com/claude-code) — full documentation
- [everything-claude-code](https://github.com/affaan-m/everything-claude-code) — Agent harness performance system: 30 agents, 135+ skills, 59 slash commands, hooks, and security rules for Claude Code
- [rtk](https://github.com/rtk-ai/rtk) — Rust Token Killer: compresses Bash output before it reaches Claude, saving ~80% tokens per session (`rtk gain` to see savings)
