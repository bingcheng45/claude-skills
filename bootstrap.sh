#!/usr/bin/env bash
# Claude Code Full Environment Bootstrap
# Usage:
#   Install:  bash ~/.claude/skills/bootstrap.sh
#   Update:   bash ~/.claude/skills/bootstrap.sh --update
#   From scratch: bash <(curl -fsSL https://raw.githubusercontent.com/bingcheng45/claude-skills/main/bootstrap.sh)
#   Update from web: bash <(curl -fsSL https://raw.githubusercontent.com/bingcheng45/claude-skills/main/bootstrap.sh) --update

set -euo pipefail

CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
SKILLS_REPO="https://github.com/bingcheng45/claude-skills.git"
ECC_REPO="https://github.com/affaan-m/everything-claude-code.git"
UPDATE_MODE=false

# Parse flags
for arg in "$@"; do
  case "$arg" in
    --update|-u) UPDATE_MODE=true ;;
    --help|-h)
      echo "Usage: bootstrap.sh [--update]"
      echo "  (no flag)  Install everything — skip steps already done"
      echo "  --update   Re-run all steps and upgrade to latest versions"
      exit 0 ;;
  esac
done

info()    { echo "[bootstrap] $*"; }
success() { echo "[bootstrap] ✓ $*"; }
warn()    { echo "[bootstrap] ⚠ $*"; }
die()     { echo "[bootstrap] ✗ $*" >&2; exit 1; }

if $UPDATE_MODE; then
  echo "╔══════════════════════════════════════════════════════════════╗"
  echo "║              Update mode — upgrading all components          ║"
  echo "╚══════════════════════════════════════════════════════════════╝"
else
  echo "╔══════════════════════════════════════════════════════════════╗"
  echo "║              Install mode — skipping existing components     ║"
  echo "╚══════════════════════════════════════════════════════════════╝"
fi
echo ""

# ── 1. Skills repo ────────────────────────────────────────────────────────────
info "Step 1/2: Skills repo"
if [ -d "$CLAUDE_DIR/skills/.git" ]; then
  info "  Pulling latest..."
  git -C "$CLAUDE_DIR/skills" pull --ff-only || warn "  Pull failed; continuing with existing version"
else
  info "  Cloning $SKILLS_REPO ..."
  git clone "$SKILLS_REPO" "$CLAUDE_DIR/skills"
fi
success "Skills repo ready"

# ── 2. RTK ────────────────────────────────────────────────────────────────────
info "Step 2/2: RTK (Rust Token Killer)"
if command -v rtk &>/dev/null; then
  if $UPDATE_MODE && command -v brew &>/dev/null; then
    info "  Upgrading RTK..."
    brew upgrade rtk 2>/dev/null || info "  RTK already at latest"
  else
    success "RTK already installed ($(rtk --version 2>/dev/null || echo 'version unknown'))"
  fi
  rtk init -g --auto-patch 2>/dev/null || warn "  rtk init already applied or failed — check manually"
elif command -v brew &>/dev/null; then
  brew install rtk && rtk init -g --auto-patch 2>/dev/null
  success "RTK installed via brew"
else
  warn "Homebrew not found — skipping RTK. Install manually: https://github.com/rtk-ai/rtk"
fi

# ── ECC (everything-claude-code) — optional ──────────────────────────────────
info "Bonus: everything-claude-code (ECC)"
if [ -d "$CLAUDE_DIR/agents" ] && ! $UPDATE_MODE; then
  success "ECC agents already installed — skipping (use --update to refresh)"
else
  info "  Cloning ECC..."
  rm -rf /tmp/ecc-bootstrap
  git clone --depth 1 "$ECC_REPO" /tmp/ecc-bootstrap
  cp -rf /tmp/ecc-bootstrap/agents "$CLAUDE_DIR/agents"
  cp -rf /tmp/ecc-bootstrap/rules  "$CLAUDE_DIR/rules"
  # Copy only skills not already present (never overwrite custom skills)
  for d in /tmp/ecc-bootstrap/skills/*/; do
    name=$(basename "$d")
    [ ! -d "$CLAUDE_DIR/skills/$name" ] && cp -r "$d" "$CLAUDE_DIR/skills/$name"
  done
  rm -rf /tmp/ecc-bootstrap
  success "ECC installed/updated (agents, rules, skills)"
fi

# ── App Store Connect CLI — macOS only ───────────────────────────────────────
if [[ "$(uname)" == "Darwin" ]]; then
  info "Bonus: App Store Connect CLI (asc)"
  if command -v asc &>/dev/null && ! $UPDATE_MODE; then
    success "asc already installed ($(asc version 2>/dev/null || echo 'version unknown')) — skipping (use --update to upgrade)"
  elif command -v brew &>/dev/null; then
    if $UPDATE_MODE && command -v asc &>/dev/null; then
      info "  Upgrading asc..."
      brew upgrade asc 2>/dev/null || info "  asc already at latest"
    else
      info "  Installing asc via Homebrew..."
      brew install asc
    fi
    success "App Store Connect CLI installed — run 'asc auth login' to configure"
  else
    warn "Homebrew not found — skipping asc. Install manually: https://github.com/rudrankriyam/App-Store-Connect-CLI"
  fi
fi

# ── Claude Island — macOS only ───────────────────────────────────────────────
if [[ "$(uname)" == "Darwin" ]]; then
  info "Bonus: Claude Island (Dynamic Island notifications)"
  if [ -d "/Applications/Claude Island.app" ] && ! $UPDATE_MODE; then
    success "Claude Island already installed — skipping (use --update to reinstall)"
  else
    ISLAND_DMG="/tmp/ClaudeIsland.dmg"
    info "  Downloading Claude Island v1.2..."
    curl -L "https://github.com/farouqaldori/claude-island/releases/download/v1.2/ClaudeIsland-1.2.dmg" \
      -o "$ISLAND_DMG" --progress-bar
    hdiutil attach "$ISLAND_DMG" -quiet
    cp -rf "/Volumes/Claude Island/Claude Island.app" /Applications/
    hdiutil detach "/Volumes/Claude Island" -quiet
    rm -f "$ISLAND_DMG"
    success "Claude Island installed — open it from /Applications to activate hooks"
  fi
fi

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
if $UPDATE_MODE; then
echo "║              Update complete!                                ║"
else
echo "║              Bootstrap complete!                             ║"
fi
echo "╟──────────────────────────────────────────────────────────────╢"
echo "║  Next steps:                                                 ║"
echo "║  1. Restart Claude Code                                      ║"
echo "║  2. Verify skills loaded: ls ~/.claude/skills                 ║"
if [[ "$(uname)" == "Darwin" ]]; then
echo "║  3. Open Claude Island from /Applications (macOS)            ║"
fi
echo "╚══════════════════════════════════════════════════════════════╝"
