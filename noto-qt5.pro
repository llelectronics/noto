# The name of your app
TARGET = noto-qt5

# C++ sources
SOURCES += main.cpp

# C++ headers
HEADERS +=

# QML files and folders
qml.files = *.qml pages cover main.qml config.js

# The .desktop file
desktop.files = noto-qt5.desktop

# Please do not modify the following line.
include(sailfishapplication/sailfishapplication.pri)

OTHER_FILES = \
    rpm/noto-qt5.yaml \
    rpm/noto-qt5.spec \
    config.js

