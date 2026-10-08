#!/bin/bash -e
# DDJ-1000 support, taken from pioneered-by-ntamas/ddj1000-linux:
#   mapping  : "Pioneer DDJ-1000 (4 deck)" with jog-screen messages
#   bridge   : daemon that unlocks and draws the jog-wheel screens (bound to the USB device by udev)
#   audio    : DKMS build of snd-usb-audio with the DDJ-1000 quirk (built for every kernel in the image)

# --- mapping
install -m 644 files/mixxx/Pioneer-DDJ-1000-4deck.midi.xml    "${ROOTFS_DIR}/usr/share/mixxx/controllers/"
install -m 644 files/mixxx/Pioneer-DDJ-1000-4deck-scripts.js  "${ROOTFS_DIR}/usr/share/mixxx/controllers/"

# --- bridge
install -m 755 files/bridge/djbox-ddj-bridge.py    "${ROOTFS_DIR}/usr/local/bin/"
install -m 755 files/bridge/djbox-ddj-trackart.py  "${ROOTFS_DIR}/usr/local/bin/"
install -m 755 files/bridge/djbox-ddj-reconnect.sh "${ROOTFS_DIR}/usr/local/bin/"
install -D -m 644 files/bridge/ddj1000-post-auth-midi.txt  "${ROOTFS_DIR}/usr/local/share/ddj1000-post-auth-midi.txt"
install -D -m 644 files/bridge/ddj1000-jog-hid-startup.txt "${ROOTFS_DIR}/usr/local/share/ddj1000-jog-hid-startup.txt"
install -m 644 files/bridge/djbox-ddj-bridge.service    "${ROOTFS_DIR}/etc/systemd/system/"
install -m 644 files/bridge/djbox-ddj-reconnect.service "${ROOTFS_DIR}/etc/systemd/system/"
install -m 644 files/bridge/99-ddj1000-reconnect.rules  "${ROOTFS_DIR}/etc/udev/rules.d/"
install -d "${ROOTFS_DIR}/var/cache/djbox-art"

# --- DKMS source
rm -rf "${ROOTFS_DIR}/usr/src/snd-usb-audio-ddj1000-1.0"
cp -a files/snd-usb-audio-ddj1000-1.0 "${ROOTFS_DIR}/usr/src/"

on_chroot << CHEOF
set -x
# kernel headers for both Pi kernels (Pi 4 = rpi-v8, Pi 5 = rpi-2712)
apt-get install -y --no-install-recommends linux-headers-rpi-v8 linux-headers-rpi-2712 || echo "DDJ1000-WARNING: kernel headers could not be installed"
systemctl enable djbox-ddj-bridge.service
dkms add -m snd-usb-audio-ddj1000 -v 1.0 || true
built=0
for k in \$(ls /lib/modules); do
    if [ -d /lib/modules/\$k/build ]; then
        if dkms build -m snd-usb-audio-ddj1000 -v 1.0 -k \$k && dkms install -m snd-usb-audio-ddj1000 -v 1.0 -k \$k --force; then
            echo "DDJ1000-AUDIO: built for \$k"; built=\$((built+1))
        else
            echo "DDJ1000-WARNING: DKMS build FAILED for \$k"
        fi
    fi
done
echo "DDJ1000-AUDIO: modules built for \$built kernel(s)"
CHEOF
