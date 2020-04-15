# The name of your app.
# NOTICE: name defined in TARGET has a corresponding QML filename.
#         If name defined in TARGET is changed, following needs to be
#         done to match new name:
#         - corresponding QML filename must be changed
#         - desktop icon filename must be changed
#         - desktop filename must be changed
#         - icon definition filename in desktop file must be changed
TARGET = harbour-noto

CONFIG += sailfishapp

SOURCES += src/harbour-noto.cpp \
    src/folderlistmodel/fileinfothread.cpp \
    src/folderlistmodel/qquickfolderlistmodel.cpp

OTHER_FILES += qml/harbour-noto.qml \
    qml/config.js \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    qml/pages/About.qml \
    qml/pages/Note.qml \
    qml/pages/Todo.qml \
    qml/pages/noto.png \
    rpm/harbour-noto.spec \
    rpm/harbour-noto.yaml \
    harbour-noto.desktop

HEADERS += \
    src/fileio.h \
    src/folderlistmodel/fileinfothread_p.h \
    src/folderlistmodel/fileproperty_p.h \
    src/folderlistmodel/qquickfolderlistmodel.h \
    src/fmhelper.hpp \
    src/backupmanager.hpp

DISTFILES += \
    qml/pages/Components/NotoModel.qml \
    qml/pages/OpenDialog.qml \
    qml/pages/InfoBanner.qml \
    qml/pages/FancyScroller.qml \
    qml/pages/BackupPage.qml

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
