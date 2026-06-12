#!/usr/bin/env bash
# ~/.config/waybar/scripts/volume_slider.sh

# Current volume
CURRENT=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+%' | head -n1 | tr -d '%')

# Use rofi/wofi vertical menu for 0-100%
CHOICE=$(seq 0 5 100 | rofi -dmenu -i -p "VOL" -lines 10 -columns 1 | head -n1)

if [ -n "$CHOICE" ]; then
    pactl set-sink-volume @DEFAULT_SINK@ "${CHOICE}%"
fi
