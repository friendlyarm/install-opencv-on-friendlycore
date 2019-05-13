import numpy as np
import cv2 as cv
import time
import os

#
# Supported cameras
# ----------------------------------------------------------
# MCAM400 (ov4689):  https://www.friendlyarm.com/index.php?route=product/product&path=78&product_id=247
# CAM1320 (ov13850):  https://www.friendlyarm.com/index.php?route=product/product&path=78&product_id=228
# Logitech C920 pro webcam
#

# selfpath
previewDevs=[]
# mainpath
pictureDevs=[]
# camera type
cameraTypes=[]

# isp1
if os.path.exists("/sys/class/video4linux/v4l-subdev2/device/video4linux/video1") or os.path.exists("/sys/class/video4linux/v4l-subdev5/device/video4linux/video1"):
    previewDevs.append("/dev/video1")
    pictureDevs.append("/dev/video0")
    cameraTypes.append("mipi")

# isp2
if os.path.exists("/sys/class/video4linux/v4l-subdev2/device/video4linux/video5") or os.path.exists("/sys/class/video4linux/v4l-subdev5/device/video4linux/video5"):
    previewDevs.append("/dev/video5")
    pictureDevs.append("/dev/video4")
    cameraTypes.append("mipi")

# usb camera
filename="/sys/class/video4linux/video8/name"
if os.path.isfile(filename):
    file = open(filename,mode='r')
    filetxt = file.read().lower()
    file.close()
    if "camera" in filetxt or "uvc" in filetxt or "webcam" in filetxt:
        previewDevs.append("/dev/video8")
        pictureDevs.append("/dev/video8")
        cameraTypes.append("usb")

cam_width=800
cam_height=448
def get_camerasrc(index):
    if cameraTypes[index] == "mipi":
        return 'rkisp device='+previewDevs[index]+' io-mode=4 ! video/x-raw,format=NV12,width='+str(cam_width)+',height='+str(cam_height)+',framerate=30/1 ! videoconvert ! appsink'
    if cameraTypes[index] == "usb":
        return 'v4l2src device='+previewDevs[index]+' io-mode=4 ! videoconvert ! video/x-raw,format=NV12,width='+str(cam_width)+',height='+str(cam_height)+',framerate=30/1 ! videoconvert ! appsink'

if len(previewDevs) < 2:
    print("Please connect two cameras.")
    os._exit(1)

cv.namedWindow("left")
cv.namedWindow("right")
cv.moveWindow("left", 40, 80)
cv.moveWindow("right", cam_width+40, 80)

cap_left = cv.VideoCapture(get_camerasrc(0), cv.CAP_GSTREAMER)
cap_right = cv.VideoCapture(get_camerasrc(1), cv.CAP_GSTREAMER)

if not cap_left.isOpened():
    print("Cannot capture from camera1. Exiting.")
    os._exit(1)

if not cap_right.isOpened():
    print("Cannot capture from camera2. Exiting.")
    os._exit(1)

last_time = time.time()
while(True):

    ret, left_frame = cap_left.read()
    cv.imshow('left', left_frame)

    ret, right_frame = cap_right.read()
    cv.imshow('right', right_frame)

    if cv.waitKey(1) & 0xFF == ord('q'):
        break

cap_left.release()
cap_right.release()
cv.destroyAllWindows()
