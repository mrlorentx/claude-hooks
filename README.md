# omarchook

A Claude Code [hook](https://docs.anthropic.com/en/docs/claude-code/hooks) that sends a desktop notification whenever Claude Code is waiting for permission approval. Clicking the notification focuses the terminal window automatically.

Built for **Hyprland** on Linux.

## Requirements

- [Hyprland](https://hyprland.org/) window manager
- `notify-send` (libnotify) — most distros include this; [mako](https://github.com/emersion/mako) or any notification daemon that supports actions
- `jq`
- A supported terminal emulator (ghostty, kitty, alacritty, foot, or wezterm)

## Install

1. **Clone the repo**
2. **Make the script executable**
_Before_ executing scripts from an unknown source, just please make sure that you atleast **try** to understand what is going on here. I'm a nice guy, but the internet is not always a nice place.

   ```sh
   chmod +x notify.sh
   ```

3. **Set your terminal emulator**

   Open `notify.sh` and edit the `TERMINAL_PROCS` constant near the top to match your terminal:

   ```sh
   # Example: only alacritty
   TERMINAL_PROCS="alacritty|Alacritty"
   ```

   The default value covers ghostty, kitty, alacritty, foot, and wezterm-gui.

4. **Register the hook in your Claude Code settings**

   Add the following to `~/.claude/settings.json` (create it if it doesn't exist):

   ```json
   {
     "hooks": {
       "PreToolUse": [
         {
           "matcher": "",
           "hooks": [
             {
               "type": "command",
               "command": "/absolute/path/to/omarchook/notify.sh"
             }
           ]
         }
       ]
     }
   }
   ```

   Replace `/absolute/path/to/omarchook/notify.sh` with the actual path on your system.

## How it works

1. Claude Code triggers the hook when it needs permission approval.
2. The script walks up the process tree to find your terminal emulator's PID.
3. It resolves the corresponding Hyprland window address via `hyprctl`.
4. A desktop notification is sent. Clicking it brings the terminal window into focus.
5. If the terminal window can't be resolved, a plain notification is sent as a fallback.
