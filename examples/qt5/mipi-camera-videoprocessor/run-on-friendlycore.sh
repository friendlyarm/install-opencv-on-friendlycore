#!/bin/bash
. /usr/bin/setqt5env-xcb
. /etc/os-release
GEOMETRY=800x1280

if [ ${UBUNTU_CODENAME} = "focal" ]; then
    if [ -f /sys/class/graphics/fb0/modes ]; then
	    GERMETRY=`cat /sys/class/graphics/fb0/modes | cut -d'p' -f1 | cut -d':' -f2`
    else
	    echo "Not found any display, please connect hdmi or eDP lcd."
	    exit 1
    fi
else
    HDMISTATUS=`cat /sys/class/drm/card0-HDMI-A-1/status`
    if [ x$HDMISTATUS = x"disconnected" ]; then
        GEOMETRY=`cat /sys/class/drm/card0-eDP-1/mode | cut -d'p' -f1`
    else
        GEOMETRY=`cat /sys/class/drm/card0-HDMI-A-1/mode | cut -d'p' -f1`
    fi
fi
echo "GEOMETRY:${GEOMETRY}"
startx ./mipi-camera-videoprocessor --no-sandbox -geometry $GEOMETRY
