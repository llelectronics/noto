#ifndef BACKUPMANAGER_HPP
#define BACKUPMANAGER_HPP

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QProcess>
#include <QStandardPaths>
#include <QDateTime>
#include <QDebug>

class BackupManager : public QObject
{   Q_OBJECT

public:
    QString appName = "noto";

signals:
    void backupComplete();
    void restoreComplete();
    void error(QString message);

public slots:

    void backupConfig()
    {
        backupConfig(appName + "_backup" + curDate.currentDateTime().toString("yyyy_MM_dd_hh_mm_ss") +".tar.gz");
    }

    void backupConfig(QString backupName)
    {
        if (existsPath(data_dir)) {
            if (backupName.isEmpty())
                backupName = appName + "_backup" + curDate.currentDateTime().toString("yyyy_MM_dd_hh_mm_ss") +".tar.gz";
            compress.start("tar -zcf " + documents_dir + "/" + backupName + " " + data_dir + "/");
            connect(&compress, SIGNAL(finished(int)), this, SLOT(getCompressStatus(int)));
        }
        else {
            errorMsg = appName + tr(" config dir not found"); // This should never happen
            error(errorMsg);
        }
    }

    void checkBackup(QString backupFile)
    {
        //qDebug() << "[backupmanager.hpp] Called with backupFile:" + backupFile;
        if (isFile(backupFile)) {
            curBackupFile = backupFile;
            checkProcess.start("bash", QStringList() << "-c" << "tar -tf \"" + backupFile + "\" | grep harbour-" + appName + " -cim1");
            connect(&checkProcess, SIGNAL(finished(int)), this, SLOT(getCheckStatus(int)));
        }
        else {
            curBackupFile = "";
            qDebug() << "[backupmanager.hpp] backupFile does not exist";
            errorMsg = tr("File not found.");
            error(errorMsg);
        }
    }

private slots:

    void getCompressStatus(int exitCode)
    {
        if (exitCode == 0) {
            backupComplete();
        }
        else {
            QByteArray errorOut = compress.readAllStandardError();
            qDebug() << "Called the C++ slot and got following error:" << errorOut.simplified();
            errorMsg = errorOut.simplified();
            error(errorMsg);
        }
    }

    void getCheckStatus(int exitCode)
    {
        if (exitCode == 0){
            QByteArray checkoutput = checkProcess.readAllStandardOutput();
            qDebug() << "Got following checkProcess output:" << checkoutput.simplified();
            if (checkoutput.simplified() == "1") {
                validBackupFile = true;
                // extract Backup
                restoreBackup();
            } else {
                validBackupFile = false;
                errorMsg = tr("No valid Backup file. Did not find harbour-") + appName + tr(" Folder");
                error(errorMsg);
            }
        } else {
            QByteArray checkerror = checkProcess.readAllStandardError();
            qDebug() << "[backupmanager.hpp] Got following checkProcess error:" << checkerror.simplified();
            validBackupFile = false;
            errorMsg = tr("Could not verify Backup file.\n") + checkerror.simplified();
            error(errorMsg);
        }
    }

    void getDecompressStatus(int exitCode)
    {
        if (exitCode == 0) {
            restoreComplete();
        }
        else {
            QByteArray errorOut = decompress.readAllStandardError();
            qDebug() << "Called the C++ slot and got following error:" << errorOut.simplified();
            errorMsg = errorOut.simplified();
            error(errorMsg);
        }
    }

private:

    QDir *myHome;

    QString curBackupFile;
    QDateTime curDate;
    QProcess compress;
    QProcess checkProcess;
    QProcess decompress;
    bool validBackupFile;
    QString errorMsg;
    QString h = myHome->homePath();
    QString data_dir = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
    QString documents_dir = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);

    bool isFile(const QString &url)
    {
        return QFileInfo(url).isFile();
    }

    bool existsPath(const QString &url)
    {
        return QDir(url).exists();
    }

    void restoreBackup()
    {
        if (validBackupFile) {
            // TODO: Using -C / might be dangerous here as it might write other files aswell to users home directory
            //       if backup file is manipulated. Evaluate if extracting to /tmp and only copying over harbour-appName folder
            //       makes more sense.
            decompress.start("tar -xzf " + curBackupFile + " -C /");
            connect(&decompress, SIGNAL(finished(int)), this, SLOT(getDecompressStatus(int)));
        } else {
            errorMsg = tr("No valid Backup file. Did not find harbour-") + appName + tr(" Folder");
            error(errorMsg);
        }
    }
};

#endif // BACKUPMANAGER_HPP
