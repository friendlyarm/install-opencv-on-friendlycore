#!/bin/bash
set -eux

export LC_ALL=C

[ $USER = "pi" ] || {
    echo "not pi user"
    exit 1
}

export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
export WORKON_HOME=$HOME/.virtualenvs

if [ -f /usr/local/bin/virtualenvwrapper.sh ]; then
    source /usr/local/bin/virtualenvwrapper.sh
elif [ -f /usr/share/virtualenvwrapper/virtualenvwrapper.sh ]; then
    source /usr/share/virtualenvwrapper/virtualenvwrapper.sh
fi

mkvirtualenv cv

. /etc/os-release
# check rom's version
if [ ! -f /etc/friendlyelec-release ]; then
    echo "Only supports FriendlyCore."
    echo "Installation aborted."
    exit 1
fi
. /etc/friendlyelec-release

PyVER=
if [ -d /usr/local/Trolltech/Qt-5.10.0-rk64one-sdk ]; then
    if [ ${UBUNTU_CODENAME} = "focal" ]; then
        PyVER=3.8
    else
	    PyVER=3.6
    fi
elif [ -d /usr/local/Trolltech/Qt-5.10.0-nexell32-sdk ]; then
    PyVER=3.5
elif [ -d /usr/local/Trolltech/Qt-5.10.0-nexell64-sdk ]; then
    PyVER=3.5
else
    echo "Not found Qt-5.10.0 sdk, Please upgrade FriendlyCore/FriendlyDesktop to the latest version, download url: http://dl.friendlyarm.com/${BOARD}"
    echo "Installation aborted."
    exit 1
fi

# remove old cv2.so
(cd ~/.virtualenvs/cv/lib/python${PyVER}/site-packages/ && {
	rm -f cv2.so
	ln -s /usr/local/lib/python${PyVER}/dist-packages/cv2/python-${PyVER}/cv2.cpython-*.so cv2.so
	if [ $? -eq 0 ]; then
		echo "create cv2.so for pi user ok"
	else
		echo "fail to create cv2.so for pi user"
	fi
})

