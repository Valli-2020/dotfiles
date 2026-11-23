#!/usr/bin/env python3
"""Waybar module for BudsLink: battery + noise control. Argument "cycle" switches the mode."""
import json
import subprocess
import sys
import time

BUS = "io.github.maniacx.BudsLink"
ROOT = "/io/github/maniacx/BudsLink"
MGR = BUS + ".DeviceManager"
DEV = BUS + ".Device"
# shortcut: BudsLink toggle order for CMF Buds Pro 2 (off, transparency, ANC); other buds may differ
MODES = {1: "Off", 2: "Transparency", 3: "ANC"}


def bus(*args):
    r = subprocess.run(["busctl", "--user", "-j", *args], capture_output=True, text=True, timeout=5)
    return json.loads(r.stdout).get("data") if r.returncode == 0 and r.stdout.strip() else None


def main():
    # starts BudsLink via D-Bus activation and keeps the service alive (heartbeat 135 s)
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
        time.sleep(0.5)  # BudsLink publishes the new state with a 200 ms delay
        return

    alias = bus("get-property", BUS, path, DEV, "Alias") or "Buds"
    lvl = {k: state.get(f"battery{i}Level", 0) for i, k in ((1, "L"), (2, "R"), (3, "Case"))}
    mode = MODES.get(state.get("toggle1State"), "?")
    buds = [v for k, v in lvl.items() if k != "Case" and v > 0]
    text = f"󰋋 {min(buds)}% {mode}" if buds else f"󰋋 {mode}"
    parts = " · ".join(f"{k} {v}%" for k, v in lvl.items() if v > 0)
    tip = f"{alias}\n{parts}\nMode: {mode}\nClick: switch mode · Right-click: open BudsLink"
    print(json.dumps({"text": text, "tooltip": tip, "class": mode.lower()}))


if __name__ == "__main__":
    main()
