import QtQuick 2.1
import org.kde.kirigami 2.4 as Kirigami
import QtQuick.Controls 2.4 as Controls
import QtQuick.Layouts 1.2
import Qt.labs.platform 1.0 as PlatformDialog
import "qrc:///config.js" as DB

Kirigami.Page {
    id: notePage
    
    property var dataContainer
    
    property string noteTitle
    property string noteBody
    property string uid
    
    property bool _textEdited: false
    
    title: noteTitle
    
    function saveChanged() {
        if (noteTitle.length > 0 && _textEdited === true) {
            //console.log(noteUid)
            if (uid == "0") uid = DB.getUniqueId()
            //console.log(noteUid)
            DB.setNote(uid,noteTitle,noteTextEdit.text)
            //console.debug("Save note " + noteTitle.text + " with text: " + note.text + " with uid:" + noteUid)
            if (dataContainer != null) notePage.dataContainer.addNote(noteTitle,uid)
            // Update Note title when renaming note
            firstPage.updateNote(noteTitle, uid)
        }
    }
    
    
    Controls.ScrollView {
        anchors.fill: parent
        
        Controls.TextArea {
            id: noteTextEdit
            text: noteBody
            wrapMode: Controls.TextArea.WordWrap
            onTextChanged: {
                _textEdited = true
            }
            property var selectStart
            property var selectEnd
            property var curPos
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.RightButton
                onReleased: { 
                    noteTextEdit.selectStart = noteTextEdit.selectionStart;
                    noteTextEdit.selectEnd = noteTextEdit.selectionEnd;
                    noteTextEdit.curPos = noteTextEdit.cursorPosition;
                    contextMenu.popup()
                }
                propagateComposedEvents: true
            }
            Controls.Menu {
                id: contextMenu
                onOpened: {
                    noteTextEdit.cursorPosition = noteTextEdit.curPos;
                    noteTextEdit.select(noteTextEdit.selectStart,noteTextEdit.selectEnd);
                }
                Controls.MenuItem {
                    text: "Cut"
                    icon.name: "edit-cut"
                    onTriggered: { 
                        noteTextEdit.cut()
                    }
                }
                
                Controls.MenuItem {
                    text: "Copy"
                    icon.name: "edit-copy"
                    onTriggered: { 
                        noteTextEdit.copy()
                    }
                }
                
                Controls.MenuItem {
                    text: "Paste"
                    icon.name: "edit-paste"
                    onTriggered: { 
                        noteTextEdit.paste()
                    }
                }
            }
        }
    }
    
    actions {
        main: Kirigami.Action {
            text: "Save"
            iconName: "document-save"
            onTriggered: saveChanged()
        }
        left: Kirigami.Action { 
            text: "Import"
            iconName: "document-import"
            onTriggered: { 
                fileDialog.fileMode = PlatformDialog.FileDialog.OpenFile
                fileDialog.file = ''
                fileDialog.open()
            }
        }
        right: Kirigami.Action {
            text: "Export"
            iconName: "document-export"
            onTriggered: {
                fileDialog.fileMode = PlatformDialog.FileDialog.SaveFile
                fileDialog.file = noteTitle
                fileDialog.open()
            }
        }
    }

    PlatformDialog.FileDialog {
        id: fileDialog
        
        defaultSuffix: 'txt'
            folder: PlatformDialog.StandardPaths.writableLocation(PlatformDialog.StandardPaths.DocumentsLocation)
            nameFilters: [qsTr("Text file (*.txt)")]
            
            onAccepted:
            {
                if (fileMode === PlatformDialog.FileDialog.SaveFile) {
                    console.debug("Save " + fileDialog.file)
                    if (fileDialog.file != "") _fileio.write(fileDialog.file, noteTextEdit.text);
                } else {
                    console.debug("Open " + fileDialog.file)
                    noteBody = _fileio.read(fileDialog.file)
                }
            }
    }
    
    Component.onCompleted: {
        if (noteTitle != null) { 
            _textEdited = false
        }
        if (noteBody != null) {
            _textEdited = false
        }
        if (noteBody == "") {
            noteTextEdit.forceActiveFocus()
        }
        
    }

}
