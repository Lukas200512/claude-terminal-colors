#!/bin/bash
# Uninstall Claude Terminal Colors

set -e

HOOK_DIR="$HOME/.claude/hooks"
SETTINGS_FILE="$HOME/.claude/settings.json"
STATE_DIR="${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}"

echo "Removing Claude Terminal Colors..."

rm -f "$HOOK_DIR/color.sh"
rm -f "$HOOK_DIR/theme.conf"
rm -rf "$HOOK_DIR/themes"
rm -f "$STATE_DIR"/.claude-terminal-color-* 2>/dev/null || true

# Strip our hooks from settings.json (matches current `color.sh` entries
# and the legacy hard-coded OSC 11 commands from older installs).
if [ -f "$SETTINGS_FILE" ]; then
    if command -v jq &> /dev/null; then
        cp "$SETTINGS_FILE" "${SETTINGS_FILE}.bak"
        jq '
          def isOurs: (.hooks // []) | map(.command // "") | join(" ") | test("color\\.sh|033\\]11");
          def clean: map(select(isOurs | not));
          if .hooks then
            .hooks.PreToolUse   |= ((. // []) | clean)
            | .hooks.PostToolUse  |= ((. // []) | clean)
            | .hooks.Stop         |= ((. // []) | clean)
            | .hooks.Notification |= ((. // []) | clean)
            | .hooks |= with_entries(select(.value | length > 0))
            | if (.hooks | length) == 0 then del(.hooks) else . end
          else . end
        ' "$SETTINGS_FILE" > "${SETTINGS_FILE}.tmp" \
          && mv "${SETTINGS_FILE}.tmp" "$SETTINGS_FILE"
        echo "Removed hook entries from settings.json (backup: ${SETTINGS_FILE}.bak)"
    else
        echo "Note: jq not found — please manually remove the hooks from $SETTINGS_FILE"
    fi
fi

# Reset terminal background
printf '\033]11;#000000\007' > /dev/tty 2>/dev/null || true

echo "Done."
