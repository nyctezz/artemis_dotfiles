#!/usr/bin/env bash
# ~/.config/waybar/scripts/backlight_slider.sh

DEVICE="intel_backlight"
MAX=$(cat /sys/class/backlight/$DEVICE/max_brightness)

# Current brightness
CURRENT=$(cat /sys/class/backlight/$DEVICE/brightness)

# Use `wofi` or `rofi` for vertical selection
# Lines = number of steps (10 here)
CHOICE=$(seq 0 $MAX | awk '{print int($1)}' | rofi -dmenu -i -p "NIT" -lines 10 -columns 1 | head -n1)

if [ -n "$CHOICE" ]; then
    echo "$CHOICE" | sudo tee /sys/class/backlight/$DEVICE/brightness > /dev/null
fi
