import QtQuick 2.1
import org.kde.kirigami 2.4 as Kirigami
import QtQuick.Controls 2.0 as Controls
import QtQuick.Layouts 1.2
import "qrc:///config.js" as DB

Kirigami.Page {
    id: root
    
    title: mainWindow.title
    
    property string _curTitle
    property string _curType
    property string _curUid
    property string _curIndex
    
    function addNote(title,uid) {
        var contains = notesModel.contains(uid)
        if (!contains[0]) {
            notesModel.append({"title": title, "type": "note", "uid":uid})
        }
        notoModel.update()
    }
    
    function updateNote(title,uid) {
        var contains = notesModel.contains(uid)
        //console.debug("[FirstPage] updateNote with uid: " + uid + " contains[0]: " + contains[0] + " contains[1]:" + contains[1])
        if (contains[0]) {
            notesModel.set(contains[1],{"title": title})
        }
    }
    
    function addTodoTitle(title) {
        if (!todoModel.containsTitle(title)) todoModel.append({"title": title, "type": "todo", "uid": ""})
            notoModel.update()
    }
    
    function getNotes() {
        DB.getNotes();
    }
    
    function setNote(title, txt) {
        DB.setNote(title,txt)
    }
    
    Component.onCompleted: {
        // Initialize the database
        DB.initialize();
        //console.log("Get Notes...")
        DB.getNotes();
        //console.log("Get Todos...")
        DB.getTodos();
    }
    
    NotoModel {
        id: notoModel
        
        function update()  {
            clear()
            for (var i=0; i<notesModel.count; i++) {
                if (searchField.text == "" || notesModel.get(i).title.toLowerCase().indexOf(searchField.text.toLowerCase()) >= 0) {
                    append(notesModel.get(i))
                }
            }
            for (var i=0; i<todoModel.count; i++) {
                if (searchField.text == "" || todoModel.get(i).title.toLowerCase().indexOf(searchField.text.toLowerCase()) >= 0) {
                    append(todoModel.get(i))
                }
            }
        }
    }
    
    NotoModel {
        id: notesModel
    }
    
    NotoModel {
        id: todoModel
    }
    
    
     actions {
        main: Kirigami.Action {
            text: "New Note"
            iconName: "document-edit"
            onTriggered: {
                createNewSheet.type = qsTr("note")
                createNewSheet.open()
            }
        }
        left: Kirigami.Action { 
            text: "Search"
            iconName: "search"
            onTriggered: { 
                searchField.visible = !searchField.visible
                if (searchField.visible) searchField.forceActiveFocus()
            }
        }
        right: Kirigami.Action {
            text: "New Todo"
            iconName: "story-editor"
            onTriggered: {
                createNewSheet.type = qsTr("todo")
                createNewSheet.open()
            }
        }
//         contextualActions: [
//             Kirigami.Action {...},
//             Kirigami.Action {...}
//         ]
    }
    
    Controls.TextField {
        id: searchField
        placeholderText: "Search..." //i18n("Search...")
        onAccepted: console.log("Search text is " + searchField.text)
        width: parent.width
        selectByMouse: true
        visible: false
        property var selectStart
        property var selectEnd
        property var curPos
        onTextChanged: {
            notoModel.update()
        }
        Kirigami.Icon {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: Kirigami.Units.smallSpacing * 2
            visible: searchField.text != ""
            source: "edit-clear"
            width: Kirigami.Units.iconSizes.small
            height: width
            MouseArea {
                anchors.fill: parent
                onClicked: searchField.text = ""
            }
        }
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            onReleased: { 
                searchField.selectStart = searchField.selectionStart;
                searchField.selectEnd = searchField.selectionEnd;
                searchField.curPos = searchField.cursorPosition;
                contextMenu.popup()
            }
            propagateComposedEvents: true
        }
        Controls.Menu {
            id: contextMenu
            onOpened: {
                searchField.cursorPosition = searchField.curPos;
                searchField.select(searchField.selectStart,searchField.selectEnd);
            }
            Controls.MenuItem {
                text: "Cut"
                icon.name: "edit-cut"
                onTriggered: { 
                    searchField.cut()
                }
            }
            
            Controls.MenuItem {
                text: "Copy"
                icon.name: "edit-copy"
                onTriggered: { 
                    searchField.copy()
                }
            }
            
            Controls.MenuItem {
                text: "Paste"
                icon.name: "edit-paste"
                onTriggered: { 
                    searchField.paste()
                }
            }
        }
    }
    
    ListView {
        id: listView
        anchors.top: searchField.visible ?  searchField.bottom : parent.top
        width: parent.width
        height: searchField.visible ? parent.height - searchField.height : parent.height
        anchors.left: parent.left
        anchors.right: parent.right
        clip: true
        
        model: notoModel
        
        delegate: Kirigami.SwipeListItem {
            contentItem: RowLayout {
                Kirigami.Icon {
                        id: typeIcon
                        source: (type == "note") ? "knotes" : "korg-todo"
                        width: Kirigami.Units.iconSizes.medium
                        height: width
                    }
                Controls.Label {
                    id: titleLabel
                    height: Math.max(implicitHeight, Kirigami.Units.iconSizes.smallMedium)
                    Layout.fillWidth: true
                    text: title
                }
//                 Controls.Menu {
//                     id: menu
//                     Controls.MenuItem {
//                         text: qsTr("Delete")
//                         icon.name: "edit-delete"
//                         onClicked: {
//                             _curTitle = title
//                             _curType = type
//                             _curUid = uid
//                             _curIndex = index
//                             deleteDrawer.open();
//                             print("Delete " + title + " clicked")
//                         }
//                     }
//                 }
//                 MouseArea {
//                     anchors.fill: parent
//                     acceptedButtons: Qt.RightButton
//                     onReleased: { 
//                         if (mouse.button === Qt.RightButton) {
//                             menu.popup()
//                         }
//                     }
//                 }
            }
            onClicked: { //showPassiveNotification("Clicked "+ title)
                if (type === "note") 
                    pageStack.push(Qt.resolvedUrl("qrc:///NotePage.qml"), { dataContainer: root, noteTitle: title, uid: uid, noteBody: DB.getText(title,uid)})
                else if (type === "todo")
                    pageStack.push(Qt.resolvedUrl("qrc:///TodoPage.qml"), { dataContainer: root, todoTitleText: title })
            }
            actions: [
            Kirigami.Action {
                icon.name: "edit-delete"
                onTriggered: { 
                    _curTitle = title
                    _curType = type
                    _curUid = uid
                    _curIndex = index
                    deleteDrawer.open();
                    print("Delete " + title + " clicked")
                }
            }
            ]
        }
        
    }
    
    Kirigami.OverlayDrawer {
        id: deleteDrawer
        edge: Qt.BottomEdge
        width: parent.width
        height: Kirigami.Settings.isMobile ? parent.height : contentItem.height + Kirigami.Units.gridUnit * 2
        contentItem: Item {
            implicitHeight: childrenRect.height + Kirigami.Units.gridUnit
            Column {
               anchors.centerIn: parent
               spacing: Kirigami.Units.largeSpacing
               Controls.Label {
                   anchors.horizontalCenter: parent.horizontalCenter
                   text: "Really delete <b>" + _curTitle + "</b>?"
               }
               Row {
                   anchors.horizontalCenter: parent.horizontalCenter
                   spacing: Kirigami.Units.largeSpacing
                   Controls.Button {
                       text: "Delete"
                       palette.button: "red"
                       palette.buttonText: "white"
                       height: Kirigami.Settings.isMobile ? Kirigami.Units.iconSizes.large : undefined
                       width: Kirigami.Settings.isMobile ? Kirigami.Units.iconSizes.large * 2 : undefined
                       onClicked: {
                           if (_curType != "note") _curUid = 0;
                           DB.remove(_curTitle,_curType,_curUid);
                           if (_curType == "note") {
                               var contains = notesModel.contains(_curUid);
                               if (contains[0]) notesModel.remove(contains[1])
                           }
                           else {
                               todoModel.removeTitle(_curTitle)
                           }
                           notoModel.remove(_curIndex);
                           deleteDrawer.close();
                       }
                   }
                   Controls.Button {
                       text: "Abort"
                       onClicked: deleteDrawer.close()
                       height: Kirigami.Settings.isMobile ? Kirigami.Units.iconSizes.large : undefined
                       width: Kirigami.Settings.isMobile ? Kirigami.Units.iconSizes.large * 2 : undefined
                   }
               }
            }
        }
    }
    
    Kirigami.OverlaySheet {
        id: createNewSheet
        
        parent: applicationWindow().overlay
        
        property string type
        
        onSheetOpenChanged: {
            if (sheetOpen) {
                if (open) newText.forceActiveFocus()
            } else {
                Qt.inputMethod.hide();
            }
        }
        
        ColumnLayout {
            spacing: Kirigami.Units.largeSpacing
            Layout.preferredWidth:  Kirigami.Units.gridUnit * 25
            Controls.Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: qsTr("Create a new %1").arg(createNewSheet.type) 
            }
            RowLayout {
                Controls.Label {
                    visible: !Kirigami.Settings.isMobile
                    text: qsTr("Name:")
                }
                Controls.TextField {
                    id: newText
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignCenter
                    placeholderText: Kirigami.Settings.isMobile ? qsTr("Name") : ""
                    Keys.onEnterPressed: { // Is that even working anywhere (just see it everywhere never worked for me
                        if (enabled) createBtn.clicked()
                    }
                    Keys.onReturnPressed: {
                        if (enabled) createBtn.clicked()
                    }
                }
            }
            RowLayout {
                Layout.alignment: Kirigami.Settings.isMobile ? Qt.AlignHCenter : Qt.AlignRight
                Controls.Button {
                    id: createBtn
                    Layout.alignment: Kirigami.Settings.isMobile ? Qt.AlignHCenter : Qt.AlignRight
                    Layout.minimumHeight: Kirigami.Settings.isMobile ? Kirigami.Units.iconSizes.large : undefined
                    Layout.minimumWidth: Kirigami.Settings.isMobile ? Kirigami.Units.iconSizes.large * 3 : undefined
                    palette.button: (newText.text.length > 0) ?"#009dff" : Kirigami.Theme.buttonAlternateBackgroundColor
                    palette.buttonText: (newText.text.length > 0) ? "white" : Kirigami.Theme.disabledTextColor
                    text: qsTr("Create")
                    highlighted: true
                    enabled: newText.text.length > 0
                    onClicked: {
                        if (createNewSheet.type == "note")
                            pageStack.push(Qt.resolvedUrl("qrc:///NotePage.qml"),{dataContainer: root, noteTitle: newText.text, uid: DB.getUniqueId(), noteBody: ""})
                        else (createNewSheet.type == "todo")
                            pageStack.push(Qt.resolvedUrl("qrc:///TodoPage.qml"),{dataContainer: root, todoTitleText: newText.text, uid: DB.getUniqueId()})
                        newText.text = ""
                        createNewSheet.close()
                    }
                }
                Controls.Button {
                    text: qsTr("Cancel")
                    onClicked: createNewSheet.close()
                    visible: !Kirigami.Settings.isMobile
                }
            }
        }
    }
    
} 
