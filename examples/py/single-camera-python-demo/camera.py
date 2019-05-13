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

if len(previewDevs) == 0:
    print("Please connect a camera.")
    os._exit(1)

cap = cv.VideoCapture(get_camerasrc(0), cv.CAP_GSTREAMER)

cv.namedWindow("left")
cv.moveWindow("left", 40, 80)

if not cap.isOpened():
    print("Cannot capture from camera. Exiting.")
    os._exit(1)
last_time = time.time()

while(True):

    ret, frame = cap.read()
    cv.imshow('left', frame)

    if cv.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv.destroyAllWindows()