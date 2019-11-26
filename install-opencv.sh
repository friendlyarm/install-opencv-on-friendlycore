#!/bin/bash

export LC_ALL=C
DOWNLOAD_SERVER="http://112.124.9.243"

# hack for me
if [ x"${HACK}" = x"1" ]; then
       DOWNLOAD_SERVER="http://192.168.1.9/files"
       [ -f matplotlib-3.0.3.tar.gz ] || wget ${DOWNLOAD_SERVER}/opencv/cache/matplotlib-3.0.3.tar.gz
       [ -f numpy-1.17.4.zip ] || wget ${DOWNLOAD_SERVER}/opencv/cache/numpy-1.17.4.zip
fi

# Everything else needs to be run as root
if [ $(id -u) -ne 0 ]; then
  printf "Script must be run as root. Try 'sudo ./install-opencv.sh'\n"
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
    CVSH=OpenCV-4.1.0-For-FriendlyELEC-RK3399.sh
    PyVER=3.6
elif [ -d /usr/local/Trolltech/Qt-5.10.0-nexell32-sdk ]; then
    CVSH=OpenCV-4.1.2-For-FriendlyCore-S5Pxx18-armhf.sh
    PyVER=3.5
elif [ -d /usr/local/Trolltech/Qt-5.10.0-nexell64-sdk ]; then
    CVSH=OpenCV-4.1.2-For-FriendlyCore-S5Pxx18-arm64.sh
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

TOPPATH=$PWD
# download opencv package
mkdir -p .cache/download
if [ ! -f .cache/${CVSH} ]; then
	apt-get -y install curl
    curl -o .cache/download/${CVSH} ${DOWNLOAD_SERVER}/opencv/${CVSH}
	rc=$?; if [ $rc != 0 ]; then exit $rc; fi;
	curl -o .cache/download/${CVSH}.hash.md5 ${DOWNLOAD_SERVER}/opencv/${CVSH}.hash.md5
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
apt-get -y purge python3-numpy
apt-get -y autoremove

# compiler 
apt-get -y install build-essential

# required
apt-get -y install cmake git libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev checkinstall libjasper-dev

# optional
apt-get -y install python3-dev python3-numpy libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libdc1394-22-dev

# ffmpeg
apt-get -y install x264 ffmpeg 

# v4l2
apt-get -y install libv4l-dev v4l-utils

# gl
apt -y install mesa-common-dev libglu1-mesa-dev freeglut3-dev

# python3
apt-get -y install python3-dev python3-pip python3-tk
pip3 install virtualenv virtualenvwrapper -i https://pypi.tuna.tsinghua.edu.cn/simple

[ -f /usr/local/bin/virtualenvwrapper.sh ] || {
    echo "Fail to install python virtualenv pkg, please check your network env and try again."
    echo "Installation aborted."
    exit 1
}

# fix v4l2 header file
(cd /usr/include/linux; [ -f videodev.h ] || ln -s ../libv4l1-videodev.h videodev.h)

function mk_virtualenv() {
    export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
    export WORKON_HOME=$HOME/.virtualenvs
    [ -d ${WORKON_HOME} ] || mkdir ${WORKON_HOME}
    export VIRTUALENVWRAPPER_HOOK_DIR=
    export ZSH_VERSION=
    source /usr/local/bin/virtualenvwrapper.sh
    mkvirtualenv cv
    deactivate
}

# check cache
# you may download this from from: http://112.124.9.243/opencv/cache/numpy-1.17.4.zip
if [ -f numpy-1.17.4.zip ]; then
    [ -d numpy-1.17.4 ] || unzip numpy-1.17.4
    (cd numpy-1.17.4 && {
        python3 setup.py install
    })
else
    pip3 install numpy
fi

# check cache
# you may download this from from: http://112.124.9.243/opencv/cache/matplotlib-3.0.3.tar.gz
if [ -f matplotlib-3.0.3.tar.gz ]; then
    [ -d matplotlib-3.0.3 ] || tar xzf matplotlib-3.0.3.tar.gz
    (cd matplotlib-3.0.3 && {
        python3 setup.py install
    })
else
    pip3 install matplotlib
fi

# install opencv
chmod 755 ./.cache/${CVSH}
./.cache/${CVSH} --skip-license --prefix=/usr/local
[ $? -ne 0 ] && {
    echo "Fail to call ${CVSH}."
    echo "Installation aborted."
    exit 1
}

# make virtualenv
mk_virtualenv
[ -d ~/.virtualenvs/cv/lib/python${PyVER}/dist-packages/ ] || mkdir -p ~/.virtualenvs/cv/lib/python${PyVER}/dist-packages


# ----------------------------
# mk link

cd ~/.virtualenvs/cv/lib/python${PyVER}/dist-packages/
rc=$?; if [ $rc != 0 ]; then exit $rc; fi;
echo "enter ~/.virtualenvs/cv/lib/python${PyVER}/dist-packages/, result: $rc"
rm -f cv2.so
ln -s /usr/local/lib/python${PyVER}/site-packages/cv2/python-${PyVER}/cv2.cpython-*.so cv2.so

cd /usr/local/lib/python${PyVER}/dist-packages/
rc=$?; if [ $rc != 0 ]; then exit $rc; fi;
echo "enter /usr/local/lib/python${PyVER}/dist-packages/, result: $rc"
rm -f cv2.so
ln -s /usr/local/lib/python${PyVER}/site-packages/cv2/python-${PyVER}/cv2.cpython-*.so cv2.so

QtEnvScript=setqt5env-eglfs
if [ x"${LINUXFAMILY}" = "xnanopi4" ]; then
	QtEnvScript=setqt5env
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
echo "# cd examples/py/"                                                                                         
echo "# . cv-env.sh" 
echo "# . ${QtEnvScript}"
echo "# python3 ver.py" 
echo "# deactivate"
echo ""                                                                                        
echo "-------" 
echo ""