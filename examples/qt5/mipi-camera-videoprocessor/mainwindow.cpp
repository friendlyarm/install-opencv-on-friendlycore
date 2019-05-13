#include "mainwindow.h"
#include "ui_mainwindow.h"
#include <QDir>
#include <QTimer>

QString readFile(const QString& filename) {
    QFile file(filename);
    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream stream(&file);
        return stream.readAll();
    }
    return "";
}

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow),isCameraFound(false)
{
    ui->setupUi(this);

    ui->graphicsView->setScene(new QGraphicsScene(this));
    ui->graphicsView->scene()->addItem(&pixmap);

    QStringList previewDevices;
    QStringList cameraTypes;

    // isp1
    if (QDir("/sys/class/video4linux/v4l-subdev2/device/video4linux/video1").exists() 
        || QDir("/sys/class/video4linux/v4l-subdev5/device/video4linux/video1").exists()) {
        previewDevices.append("/dev/video1");
        cameraTypes.append("mipi");
    }
    // isp2
    if (QDir("/sys/class/video4linux/v4l-subdev2/device/video4linux/video5").exists() 
        || QDir("/sys/class/video4linux/v4l-subdev5/device/video4linux/video5").exists()) {
        previewDevices.append("/dev/video5");
        cameraTypes.append("mipi");
    }

    // usb camera
    const QString fileName="/sys/class/video4linux/video8/name";
    if (QFile(fileName).exists()) {
        QString str=readFile(fileName);
        if (str.toLower().contains("camera") || str.toLower().contains("uvc") || str.toLower().contains("webcam")) {
            previewDevices.append("/dev/video8");
            cameraTypes.append("usb");
        }
    }

    if (previewDevices.count()>0) {
        isCameraFound =  true;

        if (cameraTypes.at(0)=="mipi") {
            ui->videoEdit->setText(QString("rkisp device=%1 io-mode=1 ! video/x-raw,format=NV12,width=800,height=448,framerate=30/1 ! videoconvert ! appsink").arg(previewDevices.at(0)));
        } else if (cameraTypes.at(0)=="usb") {
            ui->videoEdit->setText(QString("v4l2src device=%1 io-mode=4 ! videoconvert ! video/x-raw,format=NV12,width=800,height=448,framerate=30/1 ! videoconvert ! appsink").arg(previewDevices.at(0)));
        } else {
            ui->videoEdit->setText("Bug: unknow camera type");
        }
        
        QTimer::singleShot(100, this, SLOT(on_startBtn_pressed()));
    } else {
        ui->videoEdit->setText("No camera was found");
    }
}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::on_startBtn_pressed()
{
    using namespace cv;

    if(video.isOpened())
    {
        ui->startBtn->setText("Start");
        video.release();
        return;
    }

    if(!isCameraFound || !video.open(ui->videoEdit->text().trimmed().toStdString(), cv::CAP_GSTREAMER))
    {
        QMessageBox::critical(this,
                                "Video Error",
                                "Make sure you have a mipi camera connected and entered correct camera parameter!");
        return;
    }

    ui->startBtn->setText("Stop");

    Mat frame;
    while(video.isOpened())
    {
        video >> frame;
        if(!frame.empty())
        {
            copyMakeBorder(frame,
                           frame,
                           frame.rows/2,
                           frame.rows/2,
                           frame.cols/2,
                           frame.cols/2,
                           BORDER_REFLECT);

            QImage qimg(frame.data,
                        frame.cols,
                        frame.rows,
                        frame.step,
                        QImage::Format_RGB888);
            pixmap.setPixmap( QPixmap::fromImage(qimg.rgbSwapped()) );
            ui->graphicsView->fitInView(&pixmap, Qt::KeepAspectRatio);
        }
        qApp->processEvents();
    }

    ui->startBtn->setText("Start");
}

void MainWindow::closeEvent(QCloseEvent *event)
{
    if(video.isOpened())
    {
        QMessageBox::warning(this,
                             "Warning",
                             "Stop the video before closing the application!");
        event->ignore();
    }
    else
    {
        event->accept();
    }
}
