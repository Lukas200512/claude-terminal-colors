#!/bin/bash
# Uninstall Claude Terminal Colors

HOOK_DIR="$HOME/.claude/hooks"
SETTINGS_FILE="$HOME/.claude/settings.json"

echo "Removing Claude Terminal Colors..."

rm -f "$HOOK_DIR/color.sh"
rm -f "$HOOK_DIR/theme.conf"
rm -rf "$HOOK_DIR/themes"

# Reset terminal background
printf '\033]11;#000000\007' > /dev/tty

echo "Removed hook files."
echo "Note: You may need to manually remove the hooks from $SETTINGS_FILE"
echo "Done."
