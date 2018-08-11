## Installing OpenCV 3.4 in FriendlyCore (The easy way)


Shell scripts to install OpenCV 3.4 in FriendlyCore.
Here are some of the things that are going to be enabled when you are finished following through with this installation tutorial:
* Qt 5.10.0 version of the HighGUI module (Better 2D window interface with zoom, image saving capabilities, etc)
* C++ interface and examples
* C interface and examples
* Python 3.x interface and examples


## Installation 
***Note: FriendlyCore-20180810 required.  
Please download the latest FriendlyCore Image file from the following URL: http://download.friendlyarm.com***  

Run the commands below:
```
# git clone https://github.com/friendlyarm/install-opencv-on-friendlycore
# cd install-opencv-on-friendlycore
# ./install-opencv.sh
```
if you want to use pkg-config, it is recommended to add these tow lines at the end of the file ~/.bashrc and save it:
```
PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/lib/pkgconfig
export PKG_CONFIG_PATH
```


## Test python3 code
Run the commands below:
```
# cd examples
# . cv-env.sh
# python py/ver.py
```
it will activate a virtualenv, if you want to switch projects or otherwise leave your virtualenv, simply run:
```
deactivate 
```


## Building and Running a Qt 5.10 example
### How to build
```
# cd examples/qt5/CvQml/
# qmake-qt5 .
# make
```
### How to run
Connect a USB Webcam to your board, and then run the commands below:
```
# . setqt5env
# ./CvQml
```


## Examples

Here are some other examples of OpenCV:  
```
/usr/local/share/OpenCV/samples
```

## Currently supported boards 
* FriendlyELEC S5P4418 series   
* FriendlyELEC S5P6818 series   
* FriendlyELEC RK3399 series 

