#!/bin/bash -e
# Make the system behave like pioneered-by-ntamas:
#  - on-screen keyboard (shown when the skin's search box is focused), using wvkbd because this image is Wayland
#  - djbox-apply-config.py: selects the Pioneered skin in Mixxx's config once Mixxx has created it
#    (the config is NOT pre-seeded: that breaks Mixxx's database creation)
install -m 755 files/djbox-apply-config.py "${ROOTFS_DIR}/usr/local/bin/"
install -m 755 files/djbox-osk-show.sh  "${ROOTFS_DIR}/usr/local/bin/"
install -m 755 files/djbox-osk-hide.sh  "${ROOTFS_DIR}/usr/local/bin/"
install -m 755 files/djbox-prefs-toggle.sh "${ROOTFS_DIR}/usr/local/bin/"
install -m 755 files/djbox-osk-midi.py  "${ROOTFS_DIR}/usr/local/bin/"
install -m 644 files/djbox-osk-midi.service "${ROOTFS_DIR}/etc/systemd/system/"

on_chroot << CHEOF
    systemctl enable djbox-osk-midi.service
CHEOF
