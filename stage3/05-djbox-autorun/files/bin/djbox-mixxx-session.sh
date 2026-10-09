#!/bin/bash
# Kiosk loop: keep Mixxx running full-screen. Started by sway at login.
# djbox-audio.sh relies on this loop to bring Mixxx back after it kills it.
# To really stop it:  djbox-stop   (and  djbox-start  to bring it back)
STOPFILE=/tmp/djbox-stop
rm -f "$STOPFILE"
while true; do
    # one-time: select the Pioneered skin once Mixxx has written its own config
    /usr/local/bin/djbox-apply-config.py 2>/dev/null || true
    /usr/bin/mixxx --fullScreen
    [ -e "$STOPFILE" ] && exit 0
    sleep 2
done
