#!/usr/bin/env python3
"""Waybar-Modul für BudsLink: Akku + Geräuschmodus. Argument "cycle" wechselt den Modus."""
import json
import subprocess
import sys
import time

BUS = "io.github.maniacx.BudsLink"
ROOT = "/io/github/maniacx/BudsLink"
MGR = BUS + ".DeviceManager"
DEV = BUS + ".Device"
# shortcut: Reihenfolge der BudsLink-Toggles für CMF Buds Pro 2 (off, transparency, ANC); andere Buds können abweichen
MODES = {1: "Aus", 2: "Transparenz", 3: "ANC"}


def bus(*args):
    r = subprocess.run(["busctl", "--user", "-j", *args], capture_output=True, text=True, timeout=5)
    return json.loads(r.stdout).get("data") if r.returncode == 0 and r.stdout.strip() else None


def main():
    # startet BudsLink per D-Bus-Aktivierung und hält den Dienst am Leben (Heartbeat 135 s)
    bus("call", BUS, ROOT, MGR, "HoldService", "s", "waybar")
    devs = (bus("call", BUS, ROOT, MGR, "ListDevices") or [[]])[0]
    if not devs:
        print(json.dumps({"text": "", "class": "disconnected"}))
        return
    path = devs[0]
    state = json.loads(bus("get-property", BUS, path, DEV, "State") or "{}")

    if sys.argv[1:] == ["cycle"]:
        nxt = state.get("toggle1State", 1) % len(MODES) + 1
        bus("call", BUS, path, DEV, "UiAction", "si", "toggle1State", str(nxt))
        time.sleep(0.5)  # BudsLink meldet den neuen Zustand mit 200 ms Verzögerung
        return

    alias = bus("get-property", BUS, path, DEV, "Alias") or "Buds"
    lvl = {k: state.get(f"battery{i}Level", 0) for i, k in ((1, "L"), (2, "R"), (3, "Case"))}
    mode = MODES.get(state.get("toggle1State"), "?")
    buds = [v for k, v in lvl.items() if k != "Case" and v > 0]
    text = f"󰋋 {min(buds)}% {mode}" if buds else f"󰋋 {mode}"
    parts = " · ".join(f"{k} {v}%" for k, v in lvl.items() if v > 0)
    tip = f"{alias}\n{parts}\nModus: {mode}\nKlick: Modus wechseln · Rechtsklick: BudsLink öffnen"
    print(json.dumps({"text": text, "tooltip": tip, "class": mode.lower()}))


if __name__ == "__main__":
    main()
