#!/usr/bin/env python3
"""Apply the Pioneered-by-ntamas look to Mixxx's own config AFTER Mixxx has created it.

Pre-seeding ~/.mixxx/mixxx.cfg before the first run is known to break Mixxx's database setup,
so this runs from the kiosk loop before each Mixxx start and only acts once, when Mixxx has
already written a config with a Version (i.e. first-run setup is finished). Mixxx must not be running.
"""
import os
import shutil

HOME = "/home/pi/.mixxx"
CFG = HOME + "/mixxx.cfg"
MARK = HOME + "/.djbox-configured"
WANT = [
    ("Config", "ResizableSkin", "Pioneered_by_ntamas"),
    ("Waveform", "WaveformType", "19"),
    ("Waveform", "WaveformOverviewType", "0"),
    ("Controls", "PositionDisplay", "1"),
    ("Controls", "TimeFormat", "1"),
    ("Controller", "VirMIDI_5-0", "1"),
    ("ControllerPreset", "VirMIDI_5-0", "Time-Clamp.midi.xml"),
]


def main():
    if os.path.exists(MARK) or not os.path.exists(CFG):
        return
    lines = open(CFG, encoding="utf-8").read().split("\n")
    if not any(l.startswith("Version ") for l in lines):
        return
    shutil.copy(CFG, CFG + ".djbox-backup")
    for group, key, val in WANT:
        header = "[%s]" % group
        if header in lines:
            i = lines.index(header)
            j = i + 1
            while j < len(lines) and not lines[j].startswith("["):
                if lines[j].startswith(key + " ") or lines[j] == key:
                    lines[j] = "%s %s" % (key, val)
                    break
                j += 1
            else:
                lines.insert(i + 1, "%s %s" % (key, val))
        else:
            while lines and lines[-1] == "":
                lines.pop()
            lines += ["", header, "%s %s" % (key, val), ""]
    open(CFG, "w", encoding="utf-8").write("\n".join(lines))
    os.makedirs(HOME + "/controllers", exist_ok=True)
    for f in ("Time-Clamp.midi.xml", "Time-Clamp-scripts.js"):
        src = "/usr/share/mixxx/controllers/" + f
        if os.path.exists(src):
            shutil.copy(src, HOME + "/controllers/" + f)
    open(MARK, "w").close()


if __name__ == "__main__":
    main()
