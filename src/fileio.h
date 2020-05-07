#ifndef FILEIO_H
#define FILEIO_H

#include <QObject>
#include <QFile>
#include <QUrl>
#include <QTextStream>

class FileIO : public QObject
{
    Q_OBJECT

public slots:
    QByteArray read(const QString& source)
    {
        if (source.isEmpty())
            return "Error reading file";

        QUrl fileSource = source;
        QFile file(fileSource.toLocalFile());
        if (!file.open(QFile::ReadOnly))
            return "File can't be opened";

        return file.readAll();
    }
    bool write(const QString& source, const QString& data)
    {
        if (source.isEmpty())
            return false;

        QUrl fileSource = source;
        QFile file(fileSource.toLocalFile());
        if (!file.open(QFile::WriteOnly | QFile::Truncate))
            return false;

        QTextStream out(&file);
        out << data;
        file.close();
        return true;
    }

public:
    FileIO() {}
};

#endif // FILEIO_H
