#!/bin/bash -e
# Make the system look and behave like pioneered-by-ntamas:
#  - Pioneered_by_ntamas skin selected by default (+ recommended waveform/time settings, VirMIDI mapping on)
#  - on-screen keyboard (shown when the skin's search box is focused), using wvkbd because this image is Wayland
install -d -m 755 "${ROOTFS_DIR}/home/pi/.mixxx/controllers"
install -m 644 files/mixxx.cfg "${ROOTFS_DIR}/home/pi/.mixxx/mixxx.cfg"
install -m 644 ../05-djbox-autorun/files/controllers/Time-Clamp.midi.xml    "${ROOTFS_DIR}/home/pi/.mixxx/controllers/"
install -m 644 ../05-djbox-autorun/files/controllers/Time-Clamp-scripts.js  "${ROOTFS_DIR}/home/pi/.mixxx/controllers/"

install -m 755 files/djbox-osk-show.sh  "${ROOTFS_DIR}/usr/local/bin/"
install -m 755 files/djbox-osk-hide.sh  "${ROOTFS_DIR}/usr/local/bin/"
install -m 755 files/djbox-prefs-toggle.sh "${ROOTFS_DIR}/usr/local/bin/"
install -m 755 files/djbox-osk-midi.py  "${ROOTFS_DIR}/usr/local/bin/"
install -m 644 files/djbox-osk-midi.service "${ROOTFS_DIR}/etc/systemd/system/"

on_chroot << CHEOF
    chown -R pi:pi /home/pi/.mixxx
    systemctl enable djbox-osk-midi.service
CHEOF
