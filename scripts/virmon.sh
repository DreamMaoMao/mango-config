#!/bin/bash

# Function to find the first HEADLESS-* display
find_headless_display() {
    wlr-randr --json | jq -r '.[] | select(.name | startswith("HEADLESS-")) | .name' | head -n 1
}

# Get the first HEADLESS display
HEADLESS_DISPLAY=$(find_headless_display)

if [ -z "$HEADLESS_DISPLAY" ]; then
    mmsg dispatch create_virtual_output
    notify-send "Creating virtual monitor"
    HEADLESS_DISPLAY=$(find_headless_display)
    # wlr-randr --output "$HEADLESS_DISPLAY" --pos 1926,0 --scale 1 --custom-mode 1920x1080@60Hz --on
    # wlr-randr --output eDP-1 --pos 0,0 --scale 1 
    notify-send "Starting sunshine"
    sunshine &
    notify-send "Sunshine on"
    exit 0
fi

# Now check and toggle status
enable=$(wlr-randr --json | jq --arg name "$HEADLESS_DISPLAY" '.[] | select(.name == $name) | .enabled')
if [ "$enable" == "true" ]; then
    wlr-randr --output "$HEADLESS_DISPLAY" --off
    pkill sunshine
    notify-send "Sunshine off"
    mmsg dispatch destroy_all_virtual_output
    notify-send "Removed virtual monitor"
    wlr-randr --output eDP-1 --pos 0,0 --scale 1
else
    wlr-randr --output "$HEADLESS_DISPLAY" --on
    sunshine &
    notify-send "Sunshine on"
fi
