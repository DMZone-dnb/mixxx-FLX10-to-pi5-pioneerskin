#!/bin/bash
# Open/close Mixxx Preferences (Wayland): Ctrl+P to open, Escape if it is already up.
export XDG_RUNTIME_DIR=/run/user/$(id -u)
export WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-wayland-1}
export SWAYSOCK=$(ls "$XDG_RUNTIME_DIR"/sway-ipc.*.sock 2>/dev/null | head -1)
if swaymsg -t get_tree 2>/dev/null | grep -q '"name": "Preferences"'; then
    wtype -k Escape
else
    wtype -M ctrl -k p -m ctrl
fi
