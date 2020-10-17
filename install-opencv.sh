#!/bin/bash

export LC_ALL=C
TOPPATH=$PWD

# Everything else needs to be run as root
if [ $(id -u) -ne 0 ]; then
  printf "Script must be run as root. Try 'sudo ./install-opencv.sh'\n"
  exit 1
fi

. /etc/os-release
# check rom's version
if [ ! -f /etc/friendlyelec-release ]; then
	echo "Only supports FriendlyCore and FriendlyDesktop."
        echo "Installation aborted."
        exit 1
fi
. /etc/friendlyelec-release

PyVER=
if [ -d /usr/local/Trolltech/Qt-5.10.0-rk64one-sdk ]; then
    if [ ${UBUNTU_CODENAME} = "focal" ]; then
        CVSH=OpenCV-4.2.0-For-FriendlyELEC-RK3399-UbuntuFocal.sh
        PyVER=3.8
    else
        CVSH=OpenCV-4.2.0-For-FriendlyELEC-RK3399.sh
        PyVER=3.6
    fi
elif [ -d /usr/local/Trolltech/Qt-5.10.0-nexell32-sdk ]; then
    CVSH=OpenCV-3.4.2-For-FriendlyCore-S5Pxx18-armhf.sh
    PyVER=3.5
elif [ -d /usr/local/Trolltech/Qt-5.10.0-nexell64-sdk ]; then
    CVSH=OpenCV-3.4.2-For-FriendlyCore-S5Pxx18-arm64.sh
    PyVER=3.5
else
    echo "Not found Qt-5.10.0 sdk, Please upgrade FriendlyCore/FriendlyDesktop to the latest version, download url: http://dl.friendlyarm.com/${BOARD}"
    echo "Installation aborted."
    exit 1
fi

if [ x"${LINUXFAMILY}" != "xnanopi4" -a x"${LINUXFAMILY}" != "xnanopi3" -a x"${LINUXFAMILY}" != "xnanopi2" ]; then
        echo "Only supports FriendlyELEC RK3399/S5P6818/S5P4418 platform."
        echo "Installation aborted."
        exit 1
fi

# download tool
apt-get update
apt-get -y install curl

TOPPATH=$PWD
# download opencv package
mkdir -p .cache/download
if [ ! -f .cache/${CVSH} ]; then
	apt-get -y install curl
    curl -o .cache/download/${CVSH} http://112.124.9.243/opencv/${CVSH}
	rc=$?; if [ $rc != 0 ]; then exit $rc; fi;
	curl -o .cache/download/${CVSH}.hash.md5 http://112.124.9.243/opencv/${CVSH}.hash.md5
	rc=$?; if [ $rc != 0 ]; then exit $rc; fi;
	cd .cache/download
	if md5sum --status -c ${CVSH}.hash.md5; then
		mv ${CVSH}* ../
	else
		echo "The file's md5sum didn't match, please check you network."
		echo "Installation aborted."
		exit 1
	fi
fi
cd ${TOPPATH}

# remove old packages
apt-get -y purge libopencv*
apt-get -y purge python-numpy
apt-get -y autoremove

# compiler 
apt-get -y install build-essential

# required ✓
apt-get -y install cmake git libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev checkinstall

# optional ✓
apt-get -y install python-dev python-numpy libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libdc1394-22-dev

# ffmpeg
apt-get -y install x264 ffmpeg 

# v4l2
apt-get -y install libv4l-dev v4l-utils

# gl
apt -y install mesa-common-dev libglu1-mesa-dev freeglut3-dev

# python3
apt-get -y install python3-dev python3-pip python3-tk
pip3 install virtualenv virtualenvwrapper -i https://pypi.douban.com/simple
# fix v4l2 header file
(cd /usr/include/linux; [ -f videodev.h ] || ln -s ../libv4l1-videodev.h videodev.h)


# remove virtualenv
rm -rf /root/.virtualenvs
rm -rf /home/pi/.virtualenvs

# create new cv
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
export WORKON_HOME=$HOME/.virtualenvs
export VIRTUALENVWRAPPER_HOOK_DIR=
export ZSH_VERSION=
source /usr/local/bin/virtualenvwrapper.sh
mkvirtualenv cv

pip3 install numpy -i https://mirrors.ustc.edu.cn/pypi/web/simple
pip3 install matplotlib -i https://mirrors.ustc.edu.cn/pypi/web/simple


# install opencv
chmod 755 ./.cache/${CVSH}
./.cache/${CVSH} --skip-license --prefix=/usr/local

# ----------------------------
# mk link for root user

cd ~/.virtualenvs/cv/lib/python${PyVER}/site-packages/
rc=$?; if [ $rc != 0 ]; then exit $rc; fi;
echo "enter ~/.virtualenvs/cv/lib/python${PyVER}/site-packages/, result: $rc"
rm -f cv2.so
ln -s /usr/local/lib/python${PyVER}/dist-packages/cv2/python-${PyVER}/cv2.cpython-*.so cv2.so

# ----------------------------
# mk link for system
if [ -d /usr/local/lib/python${PyVER}/site-packages ]; then
    ( cd /usr/local/lib/python${PyVER}/site-packages/ && {
    sudo rm -f cv2.so
    sudo ln -s /usr/local/lib/python${PyVER}/site-packages/cv2/python-${PyVER}/cv2.cpython-*.so cv2.so
    })

    if [ ! -e /usr/local/lib/python${PyVER}/site-packages/cv2.so ]; then
    echo "failed: not found /usr/local/lib/python${PyVER}/site-packages/cv2.so"
    fi
else
    if [ -d /usr/local/lib/python${PyVER}/dist-packages ]; then
        ( cd /usr/local/lib/python${PyVER}/dist-packages/ && {
            sudo rm -f cv2.so
            sudo ln -s /usr/local/lib/python${PyVER}/packages/dist-packages/cv2/python-${PyVER}/cv2.cpython-*.so cv2.so
        })
    fi
fi

QtEnvScript=setqt5env-eglfs
if [ x"${LINUXFAMILY}" = "xnanopi4" ]; then
	QtEnvScript=setqt5env
fi

if [ -f ${QtEnvScript} ]; then
	. ${QtEnvScript}
fi

echo "/usr/local/lib" > /etc/ld.so.conf.d/opencv.conf
chmod 644 /etc/ld.so.conf.d/opencv.conf
ldconfig

# --------------------------
# remove old cv (pi user)
rm -rf /home/pi/.virtualenvs/cv

# mk link for pi user
sudo -EH -u pi "$TOPPATH/utils/005-create-pi-user-cv-link.sh"

echo "It is recommended to add these tow lines at the end of the file ~/.bashrc and save it:"
echo "    PKG_CONFIG_PATH=\$PKG_CONFIG_PATH:/usr/local/lib/pkgconfig"
echo "    export PKG_CONFIG_PATH"
echo ""                                                                                                          
echo "----------------------------------"                                                                        
echo "-   Testing OpenCV Installation  -"                                                                        
echo "----------------------------------"                                                                        
echo ""                                                                                                          
echo "Test python code:" 
echo "# cd examples/py"                                                                                         
echo "# . cv-env.sh" 
echo "# python3 ver.py" 
echo "# deactivate"
echo ""                                                                                        
echo "-------" 
echo "Test Qt5/C++ code:"                                                                        
echo "Note: To run this demo you will need a MIPI Camera(ov13850 or ov4689) or a UVC Camera(logitech c920pro) and a display connected."
echo ""
echo "# cd examples/qt5/mipi-camera-videoprocessor/" 
echo "# qmake-qt5 ."
echo "# . ${QtEnvScript}"
echo "# export DISPLAY=:0.0"
echo "# make"
echo "Run on FriendlyCore:"
echo "# ./run-on-friendlycore.sh"
echo "Run on FriendlyDesktop:" 
echo "# ./mipi-camera-videoprocessor"
echo ""

