## Installing OpenCV 3.4 on FriendlyCore
The easiest way to install it is to run FriendlyELEC's script.  
Here are the packages and utilities your system will have after you follow the instructions in this tutorial:
* Qt 5.10.0 version of the HighGUI module (Better 2D window interface with zoom, image saving capabilities, etc)
* C++ interface and examples
* C interface and examples
* Python 3.5+ interface and examples


## Installation 
***Note: FriendlyCore-20180810 required.  
Please download the latest FriendlyCore Image file from the following URL: http://download.friendlyarm.com***  

Run the commands below:
```
git clone https://github.com/friendlyarm/install-opencv-on-friendlycore
cd install-opencv-on-friendlycore
./install-opencv.sh
cp examples/cv-env.sh /usr/bin/
```
if you want to use pkg-config, append the following two lines in the "~/.bashrc" file and save it:
```
PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/lib/pkgconfig
export PKG_CONFIG_PATH
```


## Test out the OpenCV3.4 and Python3 install
Run the commands below:
```
cd examples/py/
. cv-env.sh
python ver.py
```
it will activate a virtualenv, if you want to switch projects or otherwise leave your virtualenv, simply run:
```
deactivate 
```

## Build some samples included in OpenCV
### c++ sample: facedetect

![image](https://github.com/friendlyarm/install-opencv-on-friendlycore/raw/master/examples/images/lena2-300x300.png)

```
cd /usr/local/share/OpenCV/samples/cpp
g++ -ggdb facedetect.cpp -o facedetect `pkg-config --cflags --libs /usr/local/lib/pkgconfig/opencv.pc`
. setqt5env
./facedetect --cascade="/usr/local/share/OpenCV/haarcascades/haarcascade_frontalface_alt.xml" --nested-cascade="/usr/local/share/OpenCV/haarcascades/haarcascade_eye.xml" --scale=1.3 /usr/local/share/OpenCV/samples/data/data/lena.jpg
```
### python sample: turing

![image](https://github.com/friendlyarm/install-opencv-on-friendlycore/raw/master/examples/images/python-turing.png)

```
. cv-env.sh
. setqt5env
cd /usr/local/share/OpenCV/samples/python
python turing.py
```



## Building and Running a Qt 5.10 QML example
***Note: To run this demo you will need a webcam and a display connected.***  
Run the commands below:
```
cd examples/qt5/CvQml/
qmake-qt5 .
make
. setqt5env
./CvQml
```

## Currently supported boards 
* FriendlyELEC S5P4418 series   
* FriendlyELEC S5P6818 series   
* FriendlyELEC RK3399 series 

