#!/usr/bin/env bash
# Claude Code Full Environment Bootstrap
# Run once on a new machine to install all components.
# Usage: bash ~/.claude/skills/bootstrap.sh
# Or from scratch: bash <(curl -fsSL https://raw.githubusercontent.com/bingcheng45/claude-skills/main/bootstrap.sh)

set -euo pipefail

CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
SKILLS_REPO="https://github.com/bingcheng45/claude-skills.git"
ECC_REPO="https://github.com/affaan-m/everything-claude-code.git"

info()    { echo "[bootstrap] $*"; }
success() { echo "[bootstrap] ✓ $*"; }
warn()    { echo "[bootstrap] ⚠ $*"; }
die()     { echo "[bootstrap] ✗ $*" >&2; exit 1; }

# ── 1. Skills repo ────────────────────────────────────────────────────────────
info "Step 1/6: Skills repo"
if [ -d "$CLAUDE_DIR/skills/.git" ]; then
  info "  Already cloned — pulling latest..."
  git -C "$CLAUDE_DIR/skills" pull --ff-only || warn "  Pull failed; continuing with existing version"
else
  info "  Cloning $SKILLS_REPO ..."
  git clone "$SKILLS_REPO" "$CLAUDE_DIR/skills"
fi
success "Skills repo ready"

# ── 2. RTK ────────────────────────────────────────────────────────────────────
info "Step 2/6: RTK (Rust Token Killer)"
if command -v rtk &>/dev/null; then
  success "RTK already installed ($(rtk --version 2>/dev/null || echo 'version unknown'))"
else
  if command -v brew &>/dev/null; then
    brew install rtk
    success "RTK installed via brew"
  else
    die "Homebrew not found. Install RTK manually: https://github.com/rtk-ai/rtk"
  fi
fi
# Init RTK global hook (idempotent)
rtk init -g --auto-patch 2>/dev/null || warn "  rtk init already applied or failed — check manually"

# ── 3. OMC CLI ────────────────────────────────────────────────────────────────
info "Step 3/6: OMC CLI (oh-my-claude-sisyphus)"
if command -v omc &>/dev/null; then
  success "OMC CLI already installed"
else
  npm install -g oh-my-claude-sisyphus@latest
  success "OMC CLI installed"
fi

# ── 4. HUD script ─────────────────────────────────────────────────────────────
info "Step 4/6: OMC HUD script"
mkdir -p "$CLAUDE_DIR/hud"
if [ -f "$CLAUDE_DIR/hud/omc-hud.mjs" ]; then
  success "HUD script already present"
else
  cp "$CLAUDE_DIR/skills/config/omc-hud.mjs" "$CLAUDE_DIR/hud/omc-hud.mjs"
  success "HUD script installed"
fi

# ── 5. settings.json ─────────────────────────────────────────────────────────
info "Step 5/6: settings.json"
SETTINGS="$CLAUDE_DIR/settings.json"
if [ -f "$SETTINGS" ]; then
  warn "  $SETTINGS already exists — skipping (merge manually from config/settings.json if needed)"
  warn "  Key things to verify:"
  warn "    • defaultMode: 'bypassPermissions'  (NOT 'dontAsk')"
  warn "    • allow entries have NO parentheses: 'Bash' not 'Bash(*)'"
  warn "    • additionalDirectories includes '$CLAUDE_DIR'"
  warn "    • statusLine.command points to omc-hud.mjs"
else
  # Replace placeholder path with actual home dir
  sed "s|/Users/bingcheng/.claude|$CLAUDE_DIR|g" \
    "$CLAUDE_DIR/skills/config/settings.json" > "$SETTINGS"
  success "settings.json installed"
fi

# ── 6. CLAUDE.md OMC block ───────────────────────────────────────────────────
info "Step 6/6: CLAUDE.md OMC block"
CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"
if grep -q "OMC:START" "$CLAUDE_MD" 2>/dev/null; then
  success "CLAUDE.md already has OMC block"
else
  echo "" >> "$CLAUDE_MD"
  cat "$CLAUDE_DIR/skills/config/CLAUDE-omc-block.md" >> "$CLAUDE_MD"
  success "OMC block appended to CLAUDE.md"
fi

# ── ECC (everything-claude-code) — optional ──────────────────────────────────
info "Bonus: everything-claude-code (ECC)"
if [ -d "$CLAUDE_DIR/agents" ]; then
  success "ECC agents already installed ($CLAUDE_DIR/agents)"
else
  info "  Cloning ECC..."
  git clone --depth 1 "$ECC_REPO" /tmp/ecc-bootstrap
  cp -r /tmp/ecc-bootstrap/agents "$CLAUDE_DIR/agents"
  cp -r /tmp/ecc-bootstrap/rules  "$CLAUDE_DIR/rules"
  # Copy only skills not already present
  for d in /tmp/ecc-bootstrap/skills/*/; do
    name=$(basename "$d")
    [ ! -d "$CLAUDE_DIR/skills/$name" ] && cp -r "$d" "$CLAUDE_DIR/skills/$name"
  done
  rm -rf /tmp/ecc-bootstrap
  success "ECC installed (agents, rules, skills)"
fi

# ── Claude Island — macOS only ───────────────────────────────────────────────
if [[ "$(uname)" == "Darwin" ]]; then
  info "Bonus: Claude Island (Dynamic Island notifications)"
  if [ -d "/Applications/Claude Island.app" ]; then
    success "Claude Island already installed"
  else
    ISLAND_DMG="/tmp/ClaudeIsland.dmg"
    info "  Downloading Claude Island v1.2..."
    curl -L "https://github.com/farouqaldori/claude-island/releases/download/v1.2/ClaudeIsland-1.2.dmg" \
      -o "$ISLAND_DMG" --progress-bar
    hdiutil attach "$ISLAND_DMG" -quiet
    cp -r "/Volumes/Claude Island/Claude Island.app" /Applications/
    hdiutil detach "/Volumes/Claude Island" -quiet
    rm -f "$ISLAND_DMG"
    success "Claude Island installed — open it from /Applications to activate hooks"
  fi
fi

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║              Bootstrap complete!                             ║"
echo "╟──────────────────────────────────────────────────────────────╢"
echo "║  Next steps:                                                 ║"
echo "║  1. Restart Claude Code                                      ║"
echo "║  2. Run /setup  (installs OMC plugin from marketplace)       ║"
echo "║  3. Run /oh-my-claudecode:omc-doctor  (verify health)        ║"
echo "║  4. Run: omc update  (sync OMC version drift)                ║"
echo "║  5. Open Claude Island from /Applications (macOS)            ║"
echo "╚══════════════════════════════════════════════════════════════╝"
