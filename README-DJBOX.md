# mixxx-djbox-pi-gen (รวม 3 โปรเจกต์)

| # | แหล่งที่มา | ใช้ทำอะไรในโปรเจกต์นี้ |
|---|-----------|----------------------|
| 1 | mixxx-pi-gen-1.2 | **ฐานหลัก**: OS (Raspberry Pi OS bookworm 64-bit), build Mixxx จาก source, sway + waybar |
| 2 | pioneered-by-ntamas-main | **ระบบรัน auto**: สกิน `Pioneered_by_ntamas`, kiosk loop, สคริปต์เสียง, CPU→MIDI, VirMIDI |
| 3 | DDJ-FLX10 Mixxx 2.6 | mapping ของ DDJ-FLX10 (xml + js) |
| + | FLX6 mapping, สกิน XDJ OPEN SOURCE | เพิ่มโดยผู้ใช้ (`stage3/05-djbox-autorun`) |
| + | ddj1000-linux (จาก 2) | DDJ-1000: mapping 4 deck, ไดรเวอร์เสียง DKMS, โปรแกรมขับจอ jog (`stage3/06-ddj1000`) |

## สิ่งที่เปลี่ยนจาก pi-gen 1.2 เดิม
- `stage3/05-djbox-autorun/` (ใหม่) ติดตั้งสกิน, mapping, สคริปต์, systemd service
- `stage3/02-desktop/files/i3.conf`: sway เริ่ม `djbox-mixxx-session.sh` (วนรัน `mixxx --fullScreen` ใหม่ถ้าปิด/ล่ม) แทนการรัน mixxx ครั้งเดียว
- `stage3/01-install-packages/01-run.sh`: เลือก branch ของ Mixxx ด้วยตัวแปร `MIXXX_BRANCH` (ค่าเริ่มต้น `2.6`)
- `config`: `IMG_NAME=mixxx-djbox`, `MIXXX_BRANCH=2.6`

## Build (ต้องเป็น Linux + Docker, ใช้เวลานาน, ต้องมีอินเทอร์เน็ต)
```
./build-docker.sh        # ผลลัพธ์อยู่ใน deploy/ (.zip ของไฟล์ .img)
```
แฟลชด้วย Raspberry Pi Imager หรือ balenaEtcher แล้วเปิดเครื่อง → เข้า sway → Mixxx เปิดเอง
ผู้ใช้ `pi` / รหัส `mixxx` (ตั้งใหม่ได้ใน `build.sh`/config: FIRST_USER_NAME, FIRST_USER_PASS)

## ตั้งค่าครั้งแรกใน Mixxx (ทำครั้งเดียว)
1. Preferences → Interface → Skin = `Pioneered_by_ntamas`
2. Preferences → Controllers → เปิด `Pioneer DDJ-FLX10` โหลด mapping `Pioneer DDJ-FLX10`
3. เปิด `VirMIDI_5-0` โหลด mapping `Time-Clamp` (ให้สกินแสดง CPU / ปุ่มสลับมุมมอง)
4. Sound Hardware → ตั้ง Main และ **Headphones** เป็นการ์ดเสียงของ DDJ-FLX10
   (หรือใช้ `djbox-audio.sh usb|hdmi|jack`)

## คำสั่งที่เพิ่ม
- `djbox-stop` / `djbox-start` หยุด/เริ่ม kiosk loop (ถ้าปิด Mixxx จากเมนู มันจะเปิดใหม่เองใน 2 วินาที)
- `djbox-audio.sh usb|hdmi|jack|status` สลับเอาต์พุตเสียง
- `/etc/djbox-profile`: `full` (4 deck) | `2deck` | `auto`

## ข้อควรระวัง (ยังไม่ได้ทดสอบ build จริง)
- **Mixxx 2.6 บน bookworm**: mapping FLX10 เขียนสำหรับ 2.6 แต่ branch 2.6 ต้อง build ผ่านบน bookworm ได้ ถ้า build ล้ม ให้เปลี่ยนเป็น `MIXXX_BRANCH=2.5` (mapping FLX10 บางส่วน เช่น stems จะใช้ไม่ได้)
- ไม่ได้รวมส่วนเฉพาะ DDJ-1000 (DKMS ไดรเวอร์เสียง, จอ jog) และ on-screen keyboard (ใช้ X11/onboard แต่ image นี้เป็น Wayland/sway)
- Mixxx เวอร์ชันแพตช์ของ ntamas (ruler, marquee, per-deck REMAIN) ไม่ได้รวม: สกินยังใช้ได้บน Mixxx มาตรฐาน แต่บางฟีเจอร์ของสกินจะไม่ทำงาน
- ไม่ได้ใส่ `mixxx.cfg` สำเร็จรูป เพราะต้นฉบับ pi-gen ปิดไว้ (Mixxx ฟ้องเรื่อง database)

## DDJ-1000 (stage3/06-ddj1000)
- mapping `Pioneer DDJ-1000 (4 deck)` ใน Preferences -> Controllers
- `djbox-ddj-bridge.service` ปลดล็อกและวาดจอ jog เริ่มเองเมื่อเสียบเครื่อง (ผูกกับ udev)
- ไดรเวอร์เสียง DKMS (`snd-usb-audio-ddj1000`) build ตอนสร้าง image สำหรับเคอร์เนลทุกตัว (Pi 4 และ Pi 5) ดูใน log ของ build หาบรรทัดที่ขึ้นต้น `DDJ1000-`
  - ถ้าเห็น `DDJ1000-WARNING` แปลว่า build ไดรเวอร์ไม่ผ่านกับเคอร์เนลนั้น (ซอร์สเขียนมาให้เคอร์เนล 6.18) เสียงของ DDJ-1000 จะไม่ทำงาน
- VirMIDI ตั้งเป็น 4 พอร์ต (`index=5 midi_devs=4`) ใช้ร่วมกับ CPU->MIDI ของสกิน
- ตั้ง Sound Hardware: Main = ช่อง 1-2, **Headphones = ช่อง 3-4** ไม่งั้นปุ่ม CUE ไม่ทำงาน
- ไม่ได้รวม: Mixxx เวอร์ชันแพตช์ (ruler, marquee, REMAIN แยกดeck), คีย์บอร์ดบนจอ, เครื่องมือวิเคราะห์ใน `ddj1000-jog-display/tools`

## หน้าตาแบบ ntamas (stage3/07-ntamas-look) และ REV1
- ตั้งสกิน `Pioneered_by_ntamas` + ค่า waveform/เวลา + VirMIDI/Time-Clamp ให้เอง **หลังจาก Mixxx สร้าง config ของตัวเองแล้ว** (`djbox-apply-config.py` ทำงานก่อนเปิด Mixxx รอบถัดไป: ผ่านขั้นตอนครั้งแรกแล้วปิด Mixxx หนึ่งครั้งหรือรีบูต สกินจะเปลี่ยน) ไม่ได้ใส่ `mixxx.cfg` ไว้ล่วงหน้า เพราะทำให้ฐานข้อมูล Mixxx สร้างไม่ได้ (ตรงกับหมายเหตุใน pi-gen เดิม)
- แพตช์ Mixxx ของ ntamas (`stage3/01-install-packages/files/pioneered-mixxx.patch`) เขียนสำหรับ Mixxx 2.5.6: ใช้เฉพาะถ้า apply กับ 2.6 ได้ ไม่งั้น build Mixxx มาตรฐาน ดู log หา `NTAMAS-PATCH:` (ผ่าน) หรือ `NTAMAS-PATCH-WARNING` (ไม่ได้ใช้)
- คีย์บอร์ดบนจอ: ใช้ wvkbd (Wayland) แทน onboard (X11) ขึ้นเมื่อโฟกัสช่องค้นหาในสกิน
- REV1: `Pioneer DDJ-REV1 (AKOI v2.4)` (mapping สำหรับ Mixxx 2.6)
- GRV6: ยังไม่มี mapping ของ Mixxx (ไฟล์ที่ได้เป็นของ Rekordbox)
- ไม่ได้รวม: `build-mixxx-3band.sh` / `build-mixxx-scratchdt.sh` (แก้ซอร์ส Mixxx เพิ่ม), conky overlay (X11), สคริปต์ standby/power
