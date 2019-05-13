QT       += core gui

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = mipi-camera-videoprocessor
TEMPLATE = app

DEFINES += QT_DEPRECATED_WARNINGS

SOURCES += \
        main.cpp \
        mainwindow.cpp

HEADERS += \
        mainwindow.h

FORMS += \
        mainwindow.ui

INCLUDEPATH += /usr/local/include/opencv4
LIBS += -L/usr/local/lib -lopencv_core -lopencv_imgcodecs -lopencv_imgproc -lopencv_objdetect -lopencv_video -lopencv_videoio
