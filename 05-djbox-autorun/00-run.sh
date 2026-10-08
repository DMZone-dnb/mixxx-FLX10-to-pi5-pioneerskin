#!/bin/bash -e
# Auto-run Mixxx (kiosk) + Pioneered skin + DDJ-FLX10 mapping.
# Parts of this stage come from pioneered-by-ntamas; FLX10/FLX6 mappings and the XDJ OPEN SOURCE skin were added by the user.

# --- skin + controller mappings (system-wide; selected once in Mixxx Preferences)
install -d "${ROOTFS_DIR}/usr/share/mixxx/skins" "${ROOTFS_DIR}/usr/share/mixxx/controllers"
cp -r files/skins/. "${ROOTFS_DIR}/usr/share/mixxx/skins/"
install -m 644 files/controllers/* "${ROOTFS_DIR}/usr/share/mixxx/controllers/"

# --- helper scripts
install -m 755 files/bin/djbox-audio.sh            "${ROOTFS_DIR}/usr/local/bin/"
install -m 755 files/bin/djbox-cpu-midi.sh         "${ROOTFS_DIR}/usr/local/bin/"
install -m 755 files/bin/djbox-mixxx-sounddevice.py "${ROOTFS_DIR}/usr/local/bin/"
install -m 755 files/bin/djbox-mixxx-session.sh    "${ROOTFS_DIR}/usr/local/bin/"
install -m 755 files/bin/djbox-stop                "${ROOTFS_DIR}/usr/local/bin/"
install -m 755 files/bin/djbox-start               "${ROOTFS_DIR}/usr/local/bin/"

# --- virtual MIDI port + deck profile
install -m 644 files/virmidi.conf      "${ROOTFS_DIR}/etc/modprobe.d/virmidi.conf"
install -m 644 files/virmidi-load.conf "${ROOTFS_DIR}/etc/modules-load.d/virmidi.conf"
install -m 644 files/djbox-profile     "${ROOTFS_DIR}/etc/djbox-profile"

# --- services
install -m 644 files/systemd/djbox-audio.service    "${ROOTFS_DIR}/etc/systemd/system/"
install -m 644 files/systemd/djbox-cpu-midi.service "${ROOTFS_DIR}/etc/systemd/system/"
# default audio target = first USB sound card (the controller's built-in card)
echo usb > "${ROOTFS_DIR}/home/pi/.djbox-audio"

on_chroot << CHEOF
    systemctl enable djbox-audio.service djbox-cpu-midi.service
    chown pi:pi /home/pi/.djbox-audio
CHEOF
