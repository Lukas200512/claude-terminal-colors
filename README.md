# Claude Terminal Colors

Dynamic terminal background colors for [Claude Code](https://claude.ai/code). Your terminal changes color based on what Claude is doing — so you always know at a glance whether it's running a command, writing code, waiting for you, or done.

![Shell](https://img.shields.io/badge/Shell-Warm_Brown-1a0a00)
![Code](https://img.shields.io/badge/Code-Night_Blue-0a0f2e)
![Read](https://img.shields.io/badge/Read-Violet-0f0a1f)
![Agent](https://img.shields.io/badge/Agent-Teal-001a1a)
![Input](https://img.shields.io/badge/Input_Needed-Red-2a0a0a)
![Done](https://img.shields.io/badge/Done-Green-0a1a0a)

## How it works

Uses Claude Code [hooks](https://docs.anthropic.com/en/docs/claude-code/hooks) to change your terminal background via [OSC 11](https://invisible-island.net/xterm/ctlseqs/ctlseqs.html#h3-Operating-System-Commands) escape sequences.

| Status | Color | When |
|---|---|---|
| **Shell running** | Warm Brown | Claude runs a bash command |
| **Writing code** | Deep Blue | Claude edits or creates files |
| **Reading/Searching** | Dark Violet | Claude reads files or searches |
| **Subagent** | Dark Teal | A background agent is working |
| **Needs your input** | Dark Red | Claude asks you a question |
| **Thinking** | Midnight Blue | Default while Claude works |
| **Done** | Dark Green | Claude finished, your turn |
| **Notification** | Warm Orange | Background task completed |

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/Lukas200512/claude-terminal-colors/main/install.sh | bash
```

The installer will:
1. Let you pick a theme
2. Install the hook script
3. Configure your Claude Code `settings.json`
4. Back up your existing settings if present

## Themes

Three built-in themes:

- **Dark Minimal** — subtle, low-contrast (default)
- **Ocean** — cool blue tones
- **Monokai** — classic dev palette

Switch themes anytime:

```bash
cp ~/.claude/hooks/themes/ocean.conf ~/.claude/hooks/theme.conf
```

### Create your own theme

Copy any theme file and adjust the hex colors:

```bash
cp ~/.claude/hooks/themes/dark-minimal.conf ~/.claude/hooks/themes/my-theme.conf
# Edit colors, then activate:
cp ~/.claude/hooks/themes/my-theme.conf ~/.claude/hooks/theme.conf
```

## Supported terminals

| Terminal | macOS | Linux | Windows |
|---|---|---|---|
| iTerm2 | Yes | — | — |
| Kitty | Yes | Yes | — |
| Alacritty | Yes | Yes | Yes |
| WezTerm | Yes | Yes | Yes |
| Windows Terminal | — | — | Yes |
| GNOME Terminal | — | Yes | — |
| Konsole | — | Yes | — |
| Hyper | Yes | Yes | Yes |
| Tabby | Yes | Yes | Yes |
| Termux | — | Yes (Android) | — |
| foot | — | Yes (Wayland) | — |

**Not supported:** macOS Terminal.app (no OSC 11 support)

## Requirements

- [Claude Code](https://claude.ai/code) CLI
- `jq` (for parsing hook data)
- A supported terminal emulator

## Troubleshooting

### Terminal jumps to the bottom when I scroll up

Most terminal emulators have a setting called **"scroll on output"** (sometimes "follow output" or "auto-scroll on output") that snaps the view back to the prompt whenever *anything* is written to the TTY. The color hook writes an OSC 11 escape sequence each time Claude runs a tool, which counts as output — so during long sessions every tool call yanks you out of scrollback.

This installer's hook already deduplicates writes (same color in a row → no second write), which helps a lot, but it can't avoid every emit. To eliminate the jump entirely, disable scroll-on-output in your terminal:

| Terminal | Setting |
|---|---|
| iTerm2 | Preferences → Profiles → Terminal → uncheck **"Scroll to bottom on input"** (and the "on output" option if present) |
| Kitty | `scrollback_pager_history_size` aside, set `scrollback_indicator_opacity` / use `kitty_mod+up` — Kitty doesn't auto-follow by default |
| Alacritty | `scrolling.auto_scroll: false` in `alacritty.toml` |
| WezTerm | `config.scroll_to_bottom_on_input = false` |
| GNOME Terminal | Preferences → Profile → Scrolling → uncheck **"Scroll on output"** |
| Konsole | Settings → Edit Current Profile → Scrolling → uncheck **"Scroll on output"** |

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/Lukas200512/claude-terminal-colors/main/uninstall.sh | bash
```

Or manually:

```bash
rm ~/.claude/hooks/color.sh ~/.claude/hooks/theme.conf
rm -rf ~/.claude/hooks/themes
# Remove hooks from ~/.claude/settings.json
```

## License

MIT
