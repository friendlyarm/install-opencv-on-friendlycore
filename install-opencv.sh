#!/bin/bash

export LC_ALL=C

# Everything else needs to be run as root
if [ $(id -u) -ne 0 ]; then
  printf "Script must be run as root. Try 'sudo install.sh'\n"
  exit 1
fi

# check rom's version
if [ ! -f /etc/friendlyelec-release ]; then
	echo "Only supports FriendlyCore."
        echo "Installation aborted."
        exit 1
fi
. /etc/friendlyelec-release

if [ -d /usr/local/Trolltech/Qt-5.10.0-rk64one-sdk ]; then
    CVSH=OpenCV-3.4.2-For-FriendlyCore-RK3399.sh
    PyVER=3.6
elif [ -d /usr/local/Trolltech/Qt-5.10.0-nexell32-sdk ]; then
    CVSH=OpenCV-3.4.2-For-FriendlyCore-S5Pxx18-armhf.sh
    PyVER=3.5
elif [ -d /usr/local/Trolltech/Qt-5.10.0-nexell64-sdk ]; then
    CVSH=OpenCV-3.4.2-For-FriendlyCore-S5Pxx18-arm64.sh
    PyVER=3.5
else
    echo "Not found Qt-5.10.0 sdk, Please upgrade FriendlyCore to the latest version, download url: http://dl.friendlyarm.com/${BOARD}"
    echo "Installation aborted."
    exit 1
fi

if [ x"${LINUXFAMILY}" != "xnanopi4" -a x"${LINUXFAMILY}" != "xnanopi3" -a x"${LINUXFAMILY}" != "xnanopi2" ]; then
        echo "Only supports FriendlyELEC RK3399/S5P6818/S5P4418 platform."
        echo "Installation aborted."
        exit 1
fi

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

export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
export WORKON_HOME=$HOME/.virtualenvs
export VIRTUALENVWRAPPER_HOOK_DIR=
export ZSH_VERSION=
source /usr/local/bin/virtualenvwrapper.sh
mkvirtualenv cv

pip install numpy -i https://pypi.douban.com/simple
pip install matplotlib -i https://pypi.douban.com/simple

# install opencv
chmod 755 ./.cache/${CVSH}
./.cache/${CVSH} --skip-license --prefix=/usr/local

# ----------------------------
# mk link

cd ~/.virtualenvs/cv/lib/python${PyVER}/site-packages/
rc=$?; if [ $rc != 0 ]; then exit $rc; fi;
echo "enter ~/.virtualenvs/cv/lib/python${PyVER}/site-packages/, result: $rc"
rm -f cv2.so
ln -s /usr/local/lib/python${PyVER}/site-packages/cv2.cpython-*.so cv2.so

cd /usr/local/lib/python${PyVER}/site-packages/
rc=$?; if [ $rc != 0 ]; then exit $rc; fi;
echo "enter /usr/local/lib/python${PyVER}/site-packages/, result: $rc"
rm -f cv2.so
ln -s cv2.cpython-*.so cv2.so

QtEnvScript=setqt5env-eglfs
if [ x"${LINUXFAMILY}" = "xnanopi4" ]; then
	QtEnvScript=setqt5env-kms
fi

. ${QtEnvScript}
echo "/usr/local/lib" > /etc/ld.so.conf.d/opencv.conf
chmod 644 /etc/ld.so.conf.d/opencv.conf
ldconfig

echo "It is recommended to add these tow lines at the end of the file ~/.bashrc and save it:"
echo "    PKG_CONFIG_PATH=\$PKG_CONFIG_PATH:/usr/local/lib/pkgconfig"
echo "    export PKG_CONFIG_PATH"
echo ""                                                                                                          
echo "----------------------------------"                                                                        
echo "-   Testing OpenCV Installation  -"                                                                        
echo "----------------------------------"                                                                        
echo ""                                                                                                          
echo "Test python code:" 
echo "# cd examples"                                                                                         
echo "# . cv-env.sh" 
echo "# python py/ver.py" 
echo ""                                                                                        
echo "-------" 
echo "Test Qt5/C++ code:"                                                                        
echo "Note: To run this demo you will need a webcam and a display connected."
echo ""
echo "# cd examples/qt5/CvQml/" 
echo "# qmake-qt5 ."
echo "# . ${QtEnvScript}"
echo "# make && ./CvQml" 
echo ""

