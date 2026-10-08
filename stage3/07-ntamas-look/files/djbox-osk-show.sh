#!/bin/bash
# Show the on-screen keyboard (wvkbd, Wayland). Started once, then shown/hidden with signals.
export XDG_RUNTIME_DIR=/run/user/$(id -u)
export WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-wayland-1}
if pgrep -x wvkbd-mobintl >/dev/null; then
    pkill -USR2 -x wvkbd-mobintl
else
    nohup /usr/bin/wvkbd-mobintl -L 330 >/dev/null 2>&1 &
fi
