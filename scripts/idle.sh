#!/usr/bin/bash

swayidle \
	timeout 1800 'mmsg dispatch sleep_monitor' \
	resume 'mmsg dispatch wakeup_monitor' \
	timeout 300 'dimland -a 0.3' \
	resume 'bash ~/.config/mango/scripts/exitdim.sh'
