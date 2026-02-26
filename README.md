# Claude Skills

A personal collection of reusable skills for [Claude Code](https://claude.ai/claude-code) — Anthropic's AI coding assistant.

## What are Skills?

Skills are Markdown-based instruction sets that extend Claude's capabilities with custom workflows, tools, and domain knowledge. When placed in `~/.claude/skills/`, they become globally available to Claude across every project and terminal session.

Each skill lives in its own folder and contains at minimum a `SKILL.md` file with a YAML frontmatter header:

```yaml
---
name: skill-name
description: When and why Claude should use this skill
---
```

Claude automatically loads skill metadata at startup and invokes the relevant skill when a user's request matches its description.

## Structure

```
~/.claude/skills/          ← global skills directory
└── skill-name/
    ├── SKILL.md           ← required: frontmatter + instructions
    ├── agents/            ← optional: subagent instruction files
    ├── scripts/           ← optional: bundled Python/shell scripts
    ├── references/        ← optional: reference docs loaded on demand
    └── assets/            ← optional: templates, HTML, fonts, etc.
```

## Skills in this Collection

| Skill | Description |
|-------|-------------|
| [skill-creator](./skill-creator/) | Create, test, benchmark, and optimize new Claude skills using an iterative eval workflow |

## Installation

Clone this repo into your global Claude skills directory:

```bash
git clone https://github.com/bingcheng45/claude-skills.git ~/.claude/skills
```

Or add individual skills:

```bash
cp -r skill-creator ~/.claude/skills/
```

Then restart Claude Code — skills are loaded at startup.

## Adding New Skills

To create a new skill, use the `skill-creator` skill itself:

1. Open Claude Code in any project
2. Say: *"I want to create a skill for [your workflow]"*
3. Claude will guide you through drafting, testing, and optimizing it
4. Drop the resulting folder here and submit a PR

## Resources

- [Anthropic Skills Repository](https://github.com/anthropics/skills) — official skills from Anthropic
- [Claude Code Docs](https://docs.anthropic.com/claude-code) — full documentation
