#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <QUrl>
#include <QIcon>
#include "fileio.h"
//#include <KLocalizedContext>

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);
    QCoreApplication::setOrganizationName("LL");
    QCoreApplication::setOrganizationDomain("llelectronics.org");
    QCoreApplication::setApplicationName("Noto");
    
    FileIO fileIO;

    QQmlApplicationEngine engine;

    //engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
    qWarning()  << engine.offlineStoragePath();
    engine.rootContext()->setContextProperty("_fileio", &fileIO);
    engine.load(QUrl(QStringLiteral("qrc:///main.qml")));

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
