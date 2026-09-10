#!/usr/bin/bash

# Change brightness level with `light`.
# You can call this script like this:
# brightness.sh [up|down]


case $1 in
up)
    swayosd-client --brightness +2
    ;;
down)
    current_brightness=$(brightnessctl -m | cut -d, -f4 | tr -d '%')
	target_brightness=$((current_brightness - 1))

	if [ "$target_brightness" -lt 1 ]; then
		swayosd-client --brightness 1
        exit 0
	fi
    
    swayosd-client --brightness -2
    # brightnessctl set 1%-
    ;;
bup)
    brightnessctl set 1%+
    ;;
bdown)

    current_brightness=$(brightnessctl -m | cut -d, -f4 | tr -d '%')
	target_brightness=$((current_brightness - 1))


	if [ "$target_brightness" -lt 1 ]; then
		brightnessctl set 1%
        exit 0
	fi
    
    brightnessctl set 1%-
    ;;
esac