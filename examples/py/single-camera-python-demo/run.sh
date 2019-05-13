#!/bin/bash

export ARCHFLAGS="-arch aarch64"
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
export VIRTUALENVWRAPPER_VIRTUALENV=/usr/local/bin/virtualenv
export WORKON_HOME=~/.virtualenvs
source /usr/local/bin/virtualenvwrapper.sh
workon cv
. setqt5env
DISPLAY=:0.0 python3 camera.py
deactivate
