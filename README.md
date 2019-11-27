## Installing OpenCV 4.1.2 on FriendlyCore-s5pxx18
The easiest way to install it is to run FriendlyELEC's script.  
Here are the packages and utilities your system will have after you follow the instructions in this tutorial:
* Qt 5.10.0 version of the HighGUI module (Better 2D window interface with zoom, image saving capabilities, etc)
* C++ interface and examples
* C interface and examples
* Python 3.5+ interface and examples

## Currently supported boards 
* S5P6818   
NanoPC T3/T3 Plus  
NanoPi Fire3  
Smart6818  
NanoPi M3
* S5P4418  
NanoPC T2 Plus  
NanoPi Fire2a  
Smart4418  
NanoPi S2  
NanoPi M2/M2a  
  
***If you are using the rk3399 development board, please checkout to the "rk3399" branch.  ***
  
## Installation 
***Note: OpenCV has been pre-installed in FriendlyCore (Version after 20191123) and does not require manual installation.  
Please download the latest FriendlyCore Image file from the following URL: http://download.friendlyarm.com***  
  
To make it easy to test python3 examples, you may copy cv-env.sh to the system directory，run the commands below:
```
git clone https://github.com/friendlyarm/install-opencv-on-friendlycore
cd install-opencv-on-friendlycore
cp examples/py/cv-env.sh /usr/bin/
```

## Test out the OpenCV 4.1.2 and Python3 install
Run the commands below:
```
cd ~/install-opencv-on-friendlycore/examples/py/
. cv-env.sh
python3 ver.py
```
Will display:
```
4.1.2
```
it will activate a virtualenv, if you want to switch projects or otherwise leave your virtualenv, simply run:
```
deactivate 
```

## Test python sample included in OpenCV 4.1.2: turing

![image](https://github.com/friendlyarm/install-opencv-on-friendlycore/raw/master/examples/images/python-turing.png)

```
. /usr/bin/cv-env.sh
. /usr/bin/setqt5env-eglfs
cd /usr/local/share/opencv4/samples/python
python3 turing.py
```

## Python: Stereo match example

![image](https://github.com/friendlyarm/install-opencv-on-friendlycore/raw/s5pxx18/examples/images/python-stereo-match.png)

Run the commands below:
```
cd ~/install-opencv-on-friendlycore/examples/py/stereo-match-python-demo/
./run.sh
```
