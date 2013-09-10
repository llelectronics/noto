import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    anchors.fill: parent

    Label {
        id: label
        anchors.centerIn: parent
        text: "Noto"
    }

    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-l-copy"
            onTriggered: {
                pageStack.push(Qt.resolvedUrl("../pages/Note.qml"), {dataContainer: window.initialPage})
            }
        }

        CoverAction {
            iconSource: "image://theme/icon-m-levels"
            onTriggered: {
                pageStack.push(Qt.resolvedUrl("../pages/Todo.qml"), {dataContainer: window.initialPage})
            }
        }
    }
}


