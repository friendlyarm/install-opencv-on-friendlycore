#!/bin/bash

if [ -d /usr/local/Trolltech/Qt-5.10.0-rk64one-sdk ]; then
    export ARCHFLAGS="-arch aarch64"
elif [ -d /usr/local/Trolltech/Qt-5.10.0-nexell32-sdk ]; then
    export ARCHFLAGS="-arch armhf"
elif [ -d /usr/local/Trolltech/Qt-5.10.0-nexell64-sdk ]; then
    export ARCHFLAGS="-arch aarch64"
else
    echo "Not found Qt-5.10.0 sdk, Please upgrade FriendlyCore/FriendlyDesktop to the latest version, download url: http://dl.friendlyarm.com/"
    echo "Installation aborted."
exit 1
fi

[ -z $(echo $VIRTUAL_ENV | grep "virtualenvs") ] && {
    # enter python virtual env
    export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
    export VIRTUALENVWRAPPER_VIRTUALENV=/usr/local/bin/virtualenv
    export WORKON_HOME=~/.virtualenvs
    source /usr/local/bin/virtualenvwrapper.sh
    workon cv
}

. /usr/bin/setqt5env-eglfs
python3 stereo_match.py

# leave python virtual env
deactivate
