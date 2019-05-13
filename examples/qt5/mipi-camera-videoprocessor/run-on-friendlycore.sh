#!/bin/bash
. /usr/bin/setqt5env-xcb

GEOMETRY=800x1280
HDMISTATUS=`cat /sys/class/drm/card0-HDMI-A-1/status`
if [ x$HDMISTATUS = x"disconnected" ]; then
	GEOMETRY=`cat /sys/class/drm/card0-eDP-1/mode | cut -d'p' -f1`
else
	GEOMETRY=`cat /sys/class/drm/card0-HDMI-A-1/mode | cut -d'p' -f1`
fi

startx ./mipi-camera-videoprocessor --no-sandbox -geometry $GEOMETRY
