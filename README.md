# Claude Skills

A personal collection of Claude Code skills — versioned here to stay in sync across devices.

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
├── prepare-ios-review/          ← loaded by Claude ✓
├── prepare-ios-review/         ← loaded by Claude ✓
│
├── pstack/                     ← bundled plugin (44 nested skills)
│   └── skills/                 │  loaded via the pstack plugin,
│       ├── how/                │  not from this directory directly
│       └── ...
│
├── .gitignore
└── README.md
```

> **How Claude discovers skills:** Claude loads any folder with a `SKILL.md` directly inside `~/.claude/skills/<name>/SKILL.md`. Skills must be at the **root level** of this directory — nested subfolders won't be auto-loaded.

---

## Quick Start (new machine)

```bash
# One-command bootstrap — installs everything below automatically
bash <(curl -fsSL https://raw.githubusercontent.com/bingcheng45/claude-skills/main/bootstrap.sh)

# Already installed? Run this to upgrade everything to latest
bash <(curl -fsSL https://raw.githubusercontent.com/bingcheng45/claude-skills/main/bootstrap.sh) --update
# or if the repo is already cloned:
bash ~/.claude/skills/bootstrap.sh --update
```

After bootstrap: **restart Claude Code** to load the skills.

---

## Full Environment Setup (manual steps)

New Claude instances should verify all components are installed:

### 1. Skills (this repo)

```bash
# Check
ls ~/.claude/skills | wc -l   # should show 12 root skills + pstack

# Install
git clone https://github.com/bingcheng45/claude-skills.git ~/.claude/skills

# Upgrade
cd ~/.claude/skills && git pull
```

Then restart Claude Code — skills are loaded at startup.

### 2. RTK — Rust Token Killer (~80% token savings on bash output)

```bash
brew install rtk
rtk init -g --auto-patch   # installs hook + RTK.md globally
rtk gain                   # verify token savings
```

### 3. everything-claude-code (ECC) — 47 agents + language rules (optional)

Manual step — `bootstrap.sh` does **not** install ECC.

```bash
# Agents and rules only — do NOT copy ECC's skills
git clone --depth 1 https://github.com/affaan-m/everything-claude-code.git /tmp/ecc
cp -r /tmp/ecc/agents ~/.claude/agents
cp -r /tmp/ecc/rules ~/.claude/rules
rm -rf /tmp/ecc
```

Provides: 47 subagents (`~/.claude/agents/`) and language rules for common/swift/typescript/python/go/etc (`~/.claude/rules/`).

> **Do not copy `/tmp/ecc/skills/` into `~/.claude/skills/`.** ECC ships ~181 skills; that bulk copy is how this repo accumulated the 179 skills removed in `865219a`. Add ECC skills one at a time, deliberately.

### 4. App Store Connect CLI — automate iOS/macOS release workflows

Command-line tool for App Store Connect — upload builds, manage TestFlight, certificates, metadata, and Xcode Cloud from terminal or CI.

**Prerequisites**: App Store Connect API key (key ID, issuer ID, `.p8` file) from https://appstoreconnect.apple.com/access/integrations/api

```bash
# Install
brew install asc

# Authenticate (standard — uses macOS Keychain)
asc auth login \
  --name "MyApp" \
  --key-id "ABC123" \
  --issuer-id "DEF456" \
  --private-key /path/to/AuthKey.p8 \
  --network

# Headless / CI (no Keychain)
asc auth login \
  --bypass-keychain \
  --name "MyCIKey" \
  --key-id "ABC123" \
  --issuer-id "DEF456" \
  --private-key /path/to/AuthKey.p8

# Verify
asc auth doctor
asc apps list --output table
```

### 5. Claude Island — Dynamic Island notifications for macOS

macOS menu bar app that shows Claude Code activity, permission prompts, and chat history over the MacBook notch.

```bash
# Download and install
curl -L https://github.com/farouqaldori/claude-island/releases/download/v1.2/ClaudeIsland-1.2.dmg -o /tmp/ClaudeIsland.dmg
hdiutil attach /tmp/ClaudeIsland.dmg
cp -r "/Volumes/Claude Island/Claude Island.app" /Applications/
hdiutil detach "/Volumes/Claude Island"
rm /tmp/ClaudeIsland.dmg
```

Then **open Claude Island from /Applications** — it auto-installs the required hooks into `~/.claude/hooks/` on first launch. Requires macOS 15.6+.

> **tmux note**: Claude Island's messaging feature requires Claude Code to run inside tmux. Start with `tmux new-session` before launching `claude`.

**Recommended `~/.zshrc` aliases** — opens Claude Island, launches Claude inside a named tmux session, and kills the session automatically on exit:

```zsh
alias cc='open -a "Claude Island" 2>/dev/null; sleep 1; _sess="claude-$(date +%s)"; tmux new-session -s "$_sess" /bin/zsh -c "/opt/homebrew/bin/claude; tmux kill-session -t \"$_sess\" 2>/dev/null"'

# Launch Claude Code inside tmux (required for Claude Island messaging)
# Session is automatically killed when Claude exits (Ctrl+C or natural exit)
alias claude='open -a "Claude Island" 2>/dev/null; sleep 1; _sess="claude-$(date +%s)"; tmux new-session -s "$_sess" /bin/zsh -c "/opt/homebrew/bin/claude; tmux kill-session -t \"$_sess\" 2>/dev/null"'
```

Both `cc` and `claude` do the same thing: launch Claude Island, open Claude Code in a fresh tmux session, and clean up the session on exit.

**Required `~/.tmux.conf`** — enables `Shift+Enter` as newline inside Claude Code (tmux blocks extended keys by default):

```
# Pass extended key sequences (Shift+Enter, etc.) through to applications
set -g extended-keys on
set -as terminal-features 'xterm*:extkeys'
```

And add to `~/.claude/keybindings.json`:

```json
{
  "$schema": "https://www.schemastore.org/claude-code-keybindings.json",
  "$docs": "https://code.claude.com/docs/en/keybindings",
  "bindings": [
    {
      "context": "Chat",
      "bindings": {
        "shift+enter": "chat:newline"
      }
    }
  ]
}
```

---

---

## Gotchas & Fixes

These are real issues encountered during setup — read before troubleshooting:

### `Permission denied` — Claude can't write outside project directory

Two bugs in `settings.json` cause this:

1. **Wrong `defaultMode`**: `"dontAsk"` silently denies without prompting. Use `"bypassPermissions"` instead.
2. **Invalid wildcard syntax**: `"Bash(*)"` is not valid. Use bare tool names: `"Bash"`, `"Write"`, etc.
3. **Missing `additionalDirectories`**: Claude can't write to `~/.claude/` unless listed here.

Correct permissions block:

```json
"permissions": {
  "defaultMode": "bypassPermissions",
  "allow": ["Bash", "Read", "Write", "Edit", "Glob", "Grep",
            "WebFetch", "WebSearch", "NotebookRead", "NotebookEdit",
            "TodoRead", "TodoWrite"],
  "additionalDirectories": ["/Users/your-username/.claude"]
}
```

Apply this block directly to `~/.claude/settings.json`.

### Claude Island — "open in tmux to enable messaging"

Claude Island's messaging (send messages to Claude from Dynamic Island) requires a tmux session. Launch Claude Code this way:

```bash
tmux new-session -s claude
# then inside tmux:
claude
```

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
| [skill-creator](./skill-creator/) | Create new skills, modify and improve existing skills, and measure skill performance. Use when users want to create a skill… | "create a skill for X", "make a skill that does X" |
| [explain](./explain/) | Explains any concept, topic, or idea using Richard Feynman's first-principles teaching style — clear, grounded,… | "explain X", "ELI5 X", `/explain X` |
| [explain-what-agent-did](./explain-what-agent-did/) | Explains work that was just completed — a bug fix, an investigation, a refactor, a failed attempt — in plain language the… | "what did you just do", "explain in plain english" |
| [prepare-ios-review](./prepare-ios-review/) | Take an iOS app from merged code to a submission-ready App Store Connect version using the asc CLI — preflight the version… | "cut a release", "submit to App Store", "asc" |
| [resolve-pr-comments-and-review](./resolve-pr-comments-and-review/) | Work through pull request review comments end to end — fetch every thread, verify each claim against current HEAD before… | "address the review", "PR comments", "CI is red" |
| [symphony-planner](./symphony-planner/) | Decompose a feature request into parallel-safe Linear tickets ready for Symphony/Codex to execute. Use when a feature is too… | "break this into tickets", "plan for Symphony" |
| [remotion-video-creation](./remotion-video-creation/) | Best practices for Remotion - Video creation in React. 29 domain-specific rules covering 3D, animations, audio, captions,… | "make a video in React", "Remotion" |

---

## Bundled Plugin: `pstack/`

A Claude Code port of [pstack](https://github.com/cursor/plugins/tree/main/pstack) (MIT, upstream 0.14.5). Its 44 skills live under `pstack/skills/` and are loaded by the plugin, not from this directory's root.

Workflow skills: `architect`, `arena`, `automate-me`, `blast-radius`, `bro`, `create-verification-skill`, `figure-it-out`, `how`, `interrogate`, `maintain-verification-skill`, `no-comments`, `poteto-mode`, `recall`, `reflect`, `setup-pstack`, `show-me-your-work`, `swarm`, `tdd`, `teach`, `technical-writing`, `typescript-best-practices`, `unslop`, `why`

Plus 21 `principle-*` skills encoding engineering principles (fix-root-causes, prove-it-works, type-system-discipline, …).

---

## Adding New Skills

Use the `skill-creator` skill:

1. Open Claude Code in any project
2. Say: *"create a skill for [your workflow]"*
3. Claude guides you through drafting, testing, and optimizing it
4. Drop the resulting folder into `~/.claude/skills/` (repo root), commit, and push

---

## Resources

- [App Store Connect CLI](https://github.com/rudrankriyam/App-Store-Connect-CLI) — `asc`: scriptable CLI for App Store Connect — TestFlight, metadata, certificates, Xcode Cloud
- [everything-claude-code](https://github.com/affaan-m/everything-claude-code) — 47 agents, 181 skills, language rules, hooks for Claude Code
- [rtk](https://github.com/rtk-ai/rtk) — Rust Token Killer: compresses Bash output before it reaches Claude, saving ~80% tokens per session (`rtk gain` to see savings)
- [claude-island](https://github.com/farouqaldori/claude-island) — macOS Dynamic Island notifications for Claude Code (permission prompts, session activity, chat history)
- [Claude Code Docs](https://docs.anthropic.com/claude-code) — full documentation
