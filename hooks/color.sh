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
  # shellcheck disable=SC1090
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
  COLOR="$COLOR_IDLE"
else
  # PreToolUse: set color based on tool
  case "$TOOL" in
    Bash)                COLOR="$COLOR_BASH"  ;;
    Edit|Write)          COLOR="$COLOR_CODE"  ;;
    Read|Glob|Grep)      COLOR="$COLOR_READ"  ;;
    Agent)               COLOR="$COLOR_AGENT" ;;
    AskUserQuestion)     COLOR="$COLOR_INPUT" ;;
    *)                   COLOR="$COLOR_IDLE"  ;;
  esac
fi

# Dedupe consecutive same-color writes. Each write to /dev/tty can
# yank the terminal out of scrollback (most emulators "scroll on output"),
# so skipping no-op writes makes long sessions far more usable.
STATE_DIR="${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}"
STATE_FILE="$STATE_DIR/.claude-terminal-color-$PPID"
LAST_COLOR=""
[ -f "$STATE_FILE" ] && LAST_COLOR=$(cat "$STATE_FILE" 2>/dev/null)

if [ "$COLOR" != "$LAST_COLOR" ]; then
  printf '\033]11;%s\007' "$COLOR" > /dev/tty 2>/dev/null || true
  printf '%s' "$COLOR" > "$STATE_FILE" 2>/dev/null || true
fi
