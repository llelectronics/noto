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

SOURCES += src/harbour-noto.cpp

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
    src/fileio.h

