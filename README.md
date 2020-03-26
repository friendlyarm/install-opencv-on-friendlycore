## Installing OpenCV 4.2.0 on FriendlyCore/FriendlyDesktop
The easiest way to install it is to run FriendlyELEC's script.  
Here are the packages and utilities your system will have after you follow the instructions in this tutorial:
* Qt 5.10.0 version of the HighGUI module (Better 2D window interface with zoom, image saving capabilities, etc)
* C++ interface and examples
* C interface and examples
* Python 3.6+ interface and examples

## Currently supported boards 
* RK3399  
NanoPC T4  
NanoPC M4  
NanoPC NEO4  
Som-RK3399  
  
***If you are using the s5p4418/s5p6818 development board, please checkout to the "s5pxx18" branch.***
  
## Installation 
***Note: OpenCV has been pre-installed in FriendlyCore/FriendlyDesktop (Version after 201905) and does not require manual installation.  
Please download the latest FriendlyCore/FriendlyDesktop Image file from the following URL: http://download.friendlyarm.com***  
  
To make it easy to test python3 examples, you may copy cv-env.sh to the system directory，run the commands below:
```
git clone https://github.com/friendlyarm/install-opencv-on-friendlycore
cd install-opencv-on-friendlycore
cp examples/py/cv-env.sh /usr/bin/
```

## Test out the OpenCV 4.2.0 and Python3 install
Run the commands below:
```
cd ~/install-opencv-on-friendlycore/examples/py/
. cv-env.sh
python ver.py
```
Will display:
```
4.2.0
```
it will activate a virtualenv, if you want to switch projects or otherwise leave your virtualenv, simply run:
```
deactivate 
```

## Test python sample included in OpenCV 4.2.0: turing

![image](https://github.com/friendlyarm/install-opencv-on-friendlycore/raw/master/examples/images/python-turing.png)

```
. ~/install-opencv-on-friendlycore/cv-env.sh
. setqt5env
cd /usr/local/share/opencv4/samples/python
python turing.py
```

## Build Qt5 MIPI-Camera example

![image](https://github.com/friendlyarm/install-opencv-on-friendlycore/raw/rk3399/examples/images/qt5-camera.png)

***Note: To run this demo you will need a camera(ov13850/ov4689/logitech c920 pro) and a display connected.***  
Run the commands below:
```
cd ~/install-opencv-on-friendlycore/examples/qt5/mipi-camera-videoprocessor/
qmake-qt5 .
make -j4
```
Run on FriendlyDesktop:
```
su pi
. setqt5env
export DISPLAY=:0.0
./mipi-camera-videoprocessor
```
Run on FriendlyCore:
```
./run-on-friendlycore.sh
```
## Python: Stereo match example

![image](https://github.com/friendlyarm/install-opencv-on-friendlycore/raw/rk3399/examples/images/python-stereo-match.png)

Run the commands below:
```
cd ~/install-opencv-on-friendlycore/examples/py/single-camera-python-demo/
./run.sh
```

## Python: Test single camera example
***Note: To run this demo you will need a camera(ov13850/ov4689/logitech c920 pro) and a display connected.***  
Run the commands below:
```
cd ~/install-opencv-on-friendlycore/examples/py/single-camera-python-demo/
./run.sh
```

## Python: Test dual camera example
***Note: To run this demo you will need two cameras(ov13850/ov4689/logitech c920 pro) and a display connected.***  
Run the commands below:
```
cd ~/install-opencv-on-friendlycore/examples/py/dual-camera-python-demo/
./run.sh
```

## C++: Test UVC camera example

![image](https://github.com/friendlyarm/install-opencv-on-friendlycore/raw/rk3399/examples/images/cpp-opencamera.png)

***Note: To run this demo you will need a usb camera(logitech c920 pro) and a display connected.***  
Build and run the commands below:
```
git clone https://github.com/friendlyarm/rk3399-opencv-uvccamera-cpp-demo.git
cd rk3399-opencv-uvccamera-cpp-demo
mkdir build
cd build
cmake ..
make
su pi
export DISPLAY=:0.0
. setqt5env
./opencamera
```
