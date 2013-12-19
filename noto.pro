# The name of your app.
# NOTICE: name defined in TARGET has a corresponding QML filename.
#         If name defined in TARGET is changed, following needs to be
#         done to match new name:
#         - corresponding QML filename must be changed
#         - desktop icon filename must be changed
#         - desktop filename must be changed
#         - icon definition filename in desktop file must be changed
TARGET = noto

CONFIG += sailfishapp

SOURCES += src/noto.cpp

OTHER_FILES += qml/noto.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    rpm/noto.spec \
    rpm/noto.yaml \
    noto.desktop \
    qml/pages/Todo.qml \
    qml/pages/Note.qml \
    qml/config.js \
    qml/pages/About.qml

