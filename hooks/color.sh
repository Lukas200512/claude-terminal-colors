#!/bin/bash
# ============================================================
# Claude Code Terminal Colors
# Dynamic terminal background colors based on Claude's activity
# https://github.com/Lukas200512/claude-terminal-colors
# ============================================================

INPUT=$(cat)
HOOK_TYPE="$1"
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')

# Load user theme or fall back to defaults
THEME_FILE="${CLAUDE_TERMINAL_THEME:-$HOME/.claude/hooks/theme.conf}"

if [ -f "$THEME_FILE" ]; then
  source "$THEME_FILE"
fi

# Default colors (dark minimal theme)
COLOR_BASH="${COLOR_BASH:-#1a0a00}"
COLOR_CODE="${COLOR_CODE:-#0a0f2e}"
COLOR_READ="${COLOR_READ:-#0f0a1f}"
COLOR_AGENT="${COLOR_AGENT:-#001a1a}"
COLOR_INPUT="${COLOR_INPUT:-#2a0a0a}"
COLOR_IDLE="${COLOR_IDLE:-#0f1923}"
COLOR_DONE="${COLOR_DONE:-#0a1a0a}"
COLOR_NOTIFY="${COLOR_NOTIFY:-#2a1a00}"

# PostToolUse: reset to idle
if [ "$HOOK_TYPE" = "post" ]; then
  printf '\033]11;%s\007' "$COLOR_IDLE" > /dev/tty
  exit 0
fi

# PreToolUse: set color based on tool
case "$TOOL" in
  Bash)                COLOR="$COLOR_BASH"  ;;
  Edit|Write)          COLOR="$COLOR_CODE"  ;;
  Read|Glob|Grep)      COLOR="$COLOR_READ"  ;;
  Agent)               COLOR="$COLOR_AGENT" ;;
  AskUserQuestion)     COLOR="$COLOR_INPUT" ;;
  *)                   COLOR="$COLOR_IDLE"  ;;
esac

printf '\033]11;%s\007' "$COLOR" > /dev/tty
