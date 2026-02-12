#!/usr/bin/env bash
# Claude Code Notification Hook
# Fires on permission_prompt events to send a desktop notification via notify-send (mako)
# Clicking the notification focuses the terminal where Claude Code is running.

# Terminal process names to search for when walking the process tree.
# Change this to match your terminal emulator (e.g. "alacritty|Alacritty").
TERMINAL_PROCS="ghostty|kitty|alacritty|Alacritty|foot|wezterm-gui"

cat > /dev/null  # consume stdin

# Walk up the process tree to find the terminal emulator PID
find_terminal_pid() {
  local pid=$$
  while [ "$pid" -gt 1 ]; do
    local comm
    comm=$(cat /proc/"$pid"/comm 2>/dev/null) || break
    if [[ "$comm" =~ ^($TERMINAL_PROCS)$ ]]; then echo "$pid"; return 0; fi
    pid=$(awk '/PPid/ {print $2}' /proc/"$pid"/status 2>/dev/null) || break
  done
  return 1
}

# Resolve the Hyprland window address for that PID
find_window_address() {
  local term_pid=$1
  hyprctl clients -j | jq -r --argjson pid "$term_pid" '.[] | select(.pid == $pid) | .address'
}

term_pid=$(find_terminal_pid)
window_addr=$(find_window_address "$term_pid" 2>/dev/null)

if [ -n "$window_addr" ]; then
  # Background: send notification, wait for click, then focus the terminal
  (
    action=$(notify-send \
      -u critical \
      -a "Claude Code" \
      -A "default=Focus Terminal" \
      "🤖 Claude Code" \
      "Waiting for permission approval")

    if [ "$action" = "default" ]; then
      hyprctl dispatch focuswindow "address:$window_addr"
    fi
  ) &
else
  # Fallback: non-interactive notification if we can't resolve the window
  notify-send \
    -u critical \
    -a "Claude Code" \
    "🤖 Claude Code" \
    "Waiting for permission approval"
fi
