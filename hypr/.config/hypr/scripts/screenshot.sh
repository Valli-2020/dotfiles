#!/bin/bash
# Region screenshot to ~/Pictures/Screenshots and clipboard
f=~/Pictures/Screenshots/$(date +%F_%H-%M-%S).png
mkdir -p ~/Pictures/Screenshots
grim -g "$(slurp)" "$f" && wl-copy < "$f"
