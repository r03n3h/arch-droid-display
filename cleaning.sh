#! /bin/bash
kill $(ps aux | grep 'x11vnc' | awk '{print $2}')
adb kill-server
xrandr --output HDMI-1 --off
xrandr --delmode HDMI-1 2560x1600_60.00
xrandr --rmmode "2560x1600_60.00"