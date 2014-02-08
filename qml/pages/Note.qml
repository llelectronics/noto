import QtQuick 2.0
import Sailfish.Silica 1.0
import "../config.js" as DB

Page {
    id: page

    property QtObject dataContainer: null
    property string noteTitleText
    property string noteText
    property string noteUid: "0"
    // used to detect if text was edited so that we don't always write something to database if we swipe back.
    property bool textEdited: false

    showNavigationIndicator: mainWindow.applicationActive ? true : false


    function saveChanged() {
        if (noteTitle.text.length > 0 && textEdited === true) {
            console.log(noteUid)
            if (noteUid == "0") noteUid = DB.getUniqueId()
            console.log(noteUid)
            DB.setNote(noteUid,noteTitle.text,note.text)
            //console.debug("Save note " + noteTitle.text + " with text: " + note.text + " with uid:" + noteUid)
            if (dataContainer != null) page.dataContainer.addNote(noteTitle.text,noteUid)
        }
    }


    onStatusChanged: {
        if (status === PageStatus.Deactivating) {
            saveChanged();
        }
    }


    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            visible: mainWindow.applicationActive ? true : false
            MenuItem {
                text: "Save"
                onClicked: {
                    saveChanged();
                    textEdited = false;
                }

            }
        }
        // Tell SilicaFlickable the height of its content.
        contentHeight: childrenRect.height

        Component.onCompleted: {
            if (noteTitleText != null) { noteTitle.text = noteTitleText
                textEdited = false
            }
            if (noteText != null) {
                note.text = noteText
                textEdited = false
            }

        }


        TextField {
            id: noteTitle
            anchors.top: parent.top
            width: parent.width - 120
            anchors.topMargin: 20
            anchors.left: parent.left
            anchors.leftMargin: 80
            placeholderText: "Title of Note"
            focus: true
            font.pixelSize: mainWindow.applicationActive ? Theme.fontSizeMedium : Theme.fontSizeHuge
            color: mainWindow.applicationActive ? Theme.primaryColor : Theme.highlightColor
            onTextChanged: {
                // console.log("Title changed") // DEBUG
                textEdited = true
            }
            Keys.onEnterPressed: {
                note.forceActiveFocus();
            }
            Keys.onReturnPressed: {
                note.forceActiveFocus();
            }
        }

        TextArea {
            id: note
            placeholderText: "Put note in here"
            focus: false
            width: parent.width
            height: page.height - 120
            anchors.top: noteTitle.bottom
            onTextChanged: {
                // console.log("Note changed") // DEBUG
                textEdited = true
            }
            font.pixelSize: mainWindow.applicationActive ? Theme.fontSizeSmall : Theme.fontSizeHuge
        }

    }

}
