#!/usr/bin/bash

startd=$(pgrep mangobar)

if [ -n "$startd" ]; then
	pkill mangobar
else
  mangobar -c ~/.config/mango/mangobar/config.jsonc -s ~/.config/mango/mangobar/style.css 2>&1 &
fi
