#!/bin/bash
# ============================================================
# Claude Terminal Colors — Installer
# Dynamic terminal background colors for Claude Code
# ============================================================

set -e

REPO_URL="https://raw.githubusercontent.com/Lukas200512/claude-terminal-colors/main"
HOOK_DIR="$HOME/.claude/hooks"
SETTINGS_FILE="$HOME/.claude/settings.json"
THEME_DIR="$HOME/.claude/hooks/themes"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo -e "${CYAN}  Claude Terminal Colors${NC}"
echo -e "${CYAN}  Dynamic backgrounds for Claude Code${NC}"
echo ""

# Check dependencies
if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error: jq is required but not installed.${NC}"
    echo "Install it with: sudo apt install jq / brew install jq"
    exit 1
fi

# Check terminal compatibility
echo -e "${YELLOW}Supported terminals:${NC}"
echo "  iTerm2, Kitty, Alacritty, WezTerm, Windows Terminal,"
echo "  GNOME Terminal, Konsole, Hyper, Tabby, Termux"
echo ""
echo -e "${RED}Not supported:${NC}"
echo "  macOS Terminal.app (does not support OSC 11)"
echo ""

# Theme selection
echo -e "${YELLOW}Choose a theme:${NC}"
echo "  1) Dark Minimal (default) — subtle, low-contrast"
echo "  2) Ocean — cool blue tones"
echo "  3) Monokai — classic dev palette"
echo ""
read -p "Theme [1/2/3]: " THEME_CHOICE

case "$THEME_CHOICE" in
  2) THEME="ocean" ;;
  3) THEME="monokai" ;;
  *) THEME="dark-minimal" ;;
esac

# Create directories
mkdir -p "$HOOK_DIR"
mkdir -p "$THEME_DIR"

# Download files
echo ""
echo -e "${CYAN}Installing...${NC}"

curl -fsSL "$REPO_URL/hooks/color.sh" -o "$HOOK_DIR/color.sh"
chmod +x "$HOOK_DIR/color.sh"

for t in dark-minimal ocean monokai; do
  curl -fsSL "$REPO_URL/themes/${t}.conf" -o "$THEME_DIR/${t}.conf"
done

# Set selected theme
cp "$THEME_DIR/${THEME}.conf" "$HOOK_DIR/theme.conf"

# Configure Claude Code settings
if [ -f "$SETTINGS_FILE" ]; then
    echo -e "${YELLOW}Existing settings.json found.${NC}"

    # Check if hooks already configured
    if grep -q "color.sh" "$SETTINGS_FILE" 2>/dev/null; then
        echo -e "${GREEN}Hooks already configured, skipping settings update.${NC}"
    else
        echo -e "${YELLOW}Backing up to ${SETTINGS_FILE}.bak${NC}"
        cp "$SETTINGS_FILE" "${SETTINGS_FILE}.bak"

        # Merge hooks into existing settings using jq
        HOOKS_JSON='{
          "PreToolUse": [{"matcher": "*", "hooks": [{"type": "command", "command": "bash ~/.claude/hooks/color.sh pre"}]}],
          "PostToolUse": [{"matcher": "*", "hooks": [{"type": "command", "command": "bash ~/.claude/hooks/color.sh post"}]}],
          "Stop": [{"hooks": [{"type": "command", "command": "printf '"'"'\\033]11;#0a1a0a\\007'"'"' > /dev/tty"}]}],
          "Notification": [{"hooks": [{"type": "command", "command": "printf '"'"'\\033]11;#2a1a00\\007'"'"' > /dev/tty"}]}]
        }'

        jq --argjson hooks "$HOOKS_JSON" '.hooks = ($hooks + (.hooks // {}))' "$SETTINGS_FILE" > "${SETTINGS_FILE}.tmp" \
          && mv "${SETTINGS_FILE}.tmp" "$SETTINGS_FILE"

        echo -e "${GREEN}Hooks added to settings.json${NC}"
    fi
else
    # Create new settings.json
    cat > "$SETTINGS_FILE" << 'SETTINGS'
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/color.sh pre"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/color.sh post"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "printf '\\033]11;#0a1a0a\\007' > /dev/tty"
          }
        ]
      }
    ],
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "printf '\\033]11;#2a1a00\\007' > /dev/tty"
          }
        ]
      }
    ]
  }
}
SETTINGS
    echo -e "${GREEN}Created settings.json with hooks${NC}"
fi

echo ""
echo -e "${GREEN}Installed successfully!${NC}"
echo ""
echo -e "  Theme: ${CYAN}${THEME}${NC}"
echo -e "  Hook:  ${CYAN}${HOOK_DIR}/color.sh${NC}"
echo ""
echo "  To change theme later:"
echo "    cp ~/.claude/hooks/themes/<theme>.conf ~/.claude/hooks/theme.conf"
echo ""
echo -e "  ${YELLOW}Restart Claude Code for changes to take effect.${NC}"
echo ""
