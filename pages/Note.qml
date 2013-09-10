import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.theme 1.0
import "../config.js" as DB

Page {
    id: page

    property QtObject dataContainer: null
    property string noteTitleText: null
    property string noteText: null

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: "Save"
                onClicked: {
                    DB.setNote(noteTitle.text,note.text)
                    console.debug("Save note " + noteTitle.text + " with text: " + note.text)
                    if (dataContainer != null) page.dataContainer.addNote(noteTitle.text)
                }

            }
        }
        // Tell SilicaFlickable the height of its content.
        contentHeight: childrenRect.height

        Component.onCompleted: {
            if (noteTitleText != null) noteTitle.text = noteTitleText
            if (noteText != null) note.text = noteText
        }

        Column {
            width: page.width
            spacing: theme.paddingLarge
            TextField {
                id: noteTitle
                anchors.top: parent.top
                width: parent.width - 120
                anchors.topMargin: 20
                anchors.left: parent.left
                anchors.leftMargin: 80
                placeholderText: "Title of Note"
            }

            TextArea {
                id: note
                placeholderText: "Put note in here"
                focus: true
                width: parent.width
                height: page.height - 120
                anchors.top: noteTitle.bottom
            }
        }
    }

}
