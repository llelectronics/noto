import QtQuick 2.1
import org.kde.kirigami 2.4 as Kirigami
import QtQuick.Controls 2.4 as Controls
import QtQuick.Layouts 1.2
import Qt.labs.platform 1.0 as PlatformDialog
import "qrc:///config.js" as DB

Kirigami.Page {
    id: todoPage
    
    property var dataContainer
    
    property string todoTitleText
    property bool firstLoad: false
    property bool todoEdited: false
    
    property string _curTodo
    property string _curUid
    property string _curStatus
    property string _curIndex
    
    
    Component.onCompleted: {
        if (todoTitleText != null) {
            //console.log("Get Todos for " + todoTitleText + "...")
            firstLoad = true
            if (todoTitleText != "") {
                DB.getTodo(todoTitleText);
                // Renaming of todolist is not supported by database
                todoPage.title = todoTitleText
            }
        }
    }
    
    function setFirstLoadFalse() {
        firstLoad = false;
    }
    
    ListModel {
        id: indexChanged

        function add(index) {
            console.log("[Todo.qml] Add request for indexChanged with index: " + index)
            if (contains(index)) {
                console.log("Already there so ignore");
            }
            else {
                append({ "idx": index});
            }
        }
        function contains(index) {
            for (var i=0; i<count; i++) {
                if (get(i).idx == index)  { // type transformation is intended here
                    return true;
                }
            }
            return false;
        }
    }


    function saveChanged() {
        //console.log("TodoEdited:" + todoEdited)
        //console.log(todoPage.listHeaderTextField.text.length)
        if (todoPage.title.length > 0 && todoEdited === true) {
            console.debug("Saving running now")
            if (indexChanged.count == 0) { // A fallback when index can not be changed. This is much slower then the usual save
                console.debug("No changes made, resave everything")
                for (var i = 0; i < todoPageModel.count; i++) {
                    //console.debug("Save todo " + todoPage.listHeaderTextField.text + " with text: " + todoPageModel.get(i).todo + " and status:" + todoPageModel.get(i).status + " and uid:" + todoPageModel.get(i).uid) // DEBUG
                    // Remove old entries if available before saving
                    DB.remove(todoPage.title,"todo", "");
                    DB.setTodo(todoPage.title,todoPageModel.get(i).todo,todoPageModel.get(i).status,todoPageModel.get(i).uid)
                }
            }
            else {
                console.debug("Changes detected saving only changes")
                for (var i = 0; i < indexChanged.count; i++) {
                    //console.log("Saving todo at " + indexChanged.get(i).idx)
                    DB.setTodo(todoPage.title,todoPageModel.get(indexChanged.get(i).idx).todo,todoPageModel.get(indexChanged.get(i).idx).status,todoPageModel.get(indexChanged.get(i).idx).uid)
                    // Don't forget to set indexChanged to -1 to not mess up future saving
                }
                indexChanged.clear()
            }
            if (dataContainer != null) todoPage.dataContainer.addTodoTitle(todoPage.title)
                todoEdited = false
        }
    }
    
    ListModel {
        id: todoPageModel
        
        function clearDone() {
            for (var i=count-1; i>=0; i--) {
                //console.debug("[Todo.qml] Todo: " + get(i).todo + " has status: " + get(i).status)
                if (get(i).status == 1)  { // type transformation is intended here
//                     console.log("[Todo.qml] Remove done task at index: " + i);
//                     console.log("Remove from Todo " + todoPage.title + " Entry " + todoPageModel.get(i).todo + " with Uid " + todoPageModel.get(i).uid)
                    // Don't automatically save
                    //DB.removeTodoEntry(todoPage.title,todoPageModel.get(i).todo,todoPageModel.get(i).uid) // Remove from database
                    todoPageModel.remove(i); // Remove visually
                    firstLoad = false
                    todoEdited = true
                }
            }
        }
    }
    
    function addTodo(todo,status,uid) {
        //console.debug("Adding todo:" + todo + "with status:" + status + " and uid:" + uid) // DEBUG
        todoPageModel.append({"todo": todo, "status": status, "uid": uid})
        if (status === 0) listView.move(listView.count-1, 0);
        if (firstLoad === true) { todoEdited = false } else { todoEdited = true }
        //console.debug("addtodo todoedited=" + todoEdited)
    }
    
    ListView {
        id: listView
        anchors.top: parent.top
        width: parent.width
        height: parent.height
        anchors.left: parent.left
        anchors.right: parent.right
        clip: true
        
        function move(sourceIndex,targetIndex) {
            if(targetIndex >= 0 && targetIndex < todoPageModel.count){
                todoPageModel.move(sourceIndex, targetIndex, 1)
            }
        }
        
        model: todoPageModel
        
        
        delegate: Kirigami.SwipeListItem {
            id: myListItem
            property int myIndex: index
            contentItem: RowLayout {
                Controls.CheckBox {
                    id: checkBox
                    width: Kirigami.Units.iconSizes.medium
                    height: width
                    checked: { if (status == 1) true
                        else false 
                    }
                    onClicked: {
                        firstLoad = false
                        todoEdited = true
                        if (todoPageModel.get(index).status == 0)  {
                            todoPageModel.get(index).status = 1;
                            listView.move(index,todoPageModel.count-1);
                            indexChanged.add(todoPageModel.count-1);
                            saveChanged();
                        }
                        else {
                            todoPageModel.get(index).status = 0;
                            listView.move(index,0);
                            indexChanged.add(0);
                            saveChanged();
                        }
                        //                        console.log("Status changed to: " + todoModel.get(index).status + " todoEdited:" + todoEdited) // DEBUG
                    }
                }
                Controls.TextField {
                    id: todoText
                    height: Math.max(implicitHeight, Kirigami.Units.iconSizes.smallMedium)
                    Layout.fillWidth: true
                    text: todo
                    onTextChanged: {
                        if (firstLoad === true) { todoEdited = false; indexChanged.clear() }
                        else {
                            todoEdited = true
                            autoSaveTimer.restart()
                            indexChanged.add(myListItem.myIndex);
                        }
                        //console.debug("todoText textchanged todoedited=" + todoEdited)
                        todoPageModel.get(index).todo = text
                    }
                    Keys.onEnterPressed: {
                        todoPageModel.append({ "todo": "", "status": 0, "uid": DB.getUniqueId()});
                    }
                    Keys.onReturnPressed: {
                        todoPageModel.append({ "todo": "", "status": 0, "uid": DB.getUniqueId()});
                    }
                    Component.onCompleted: todoText.forceActiveFocus()
                }
            }
            actions: [
            Kirigami.Action {
                icon.name: "edit-delete"
                onTriggered: { 
                    _curTodo = todo
                    _curStatus = status
                    _curUid = uid
                    _curIndex = index
                    infoNoteDrawer.open();
                    print("Delete " + _curTodo + " clicked")
                }
            }
            ]
        }
        
    }
    
    actions {
        main: Kirigami.Action {
            text: "Save"
            iconName: "document-save"
            onTriggered: saveChanged()
        }
        left: Kirigami.Action { 
            text: "Insert task"
            iconName: "list-add"
            onTriggered: { 
                if (firstLoad == true) firstLoad = false;
                todoPageModel.append({ "todo": "", "status": 0, "uid" : DB.getUniqueId()});
                autoSaveTimer.restart();
                listView.positionViewAtEnd();
            }
        }
        right: Kirigami.Action {
            text: "Clear done tasks"
            iconName: "checkbox"
            onTriggered: {
                infoNoteDrawer.clear = true
                infoNoteDrawer.open()
            }
        }
    }
    
     Kirigami.OverlayDrawer {
        id: infoNoteDrawer
        edge: Qt.BottomEdge
        width: parent.width
        height: Kirigami.Settings.isMobile ? parent.height : contentItem.height + Kirigami.Units.gridUnit * 2
        property bool clear: false
        contentItem: Item {
            implicitHeight: childrenRect.height + Kirigami.Units.gridUnit
            Column {
               anchors.centerIn: parent
               spacing: Kirigami.Units.largeSpacing
               Controls.Label {
                   anchors.horizontalCenter: parent.horizontalCenter
                   text: infoNoteDrawer.clear ? qsTr("Clear done tasks?") : qsTr("Really delete <b>%1</b>?").arg(_curTodo)
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
                           if (!infoNoteDrawer.clear) {
                               DB.removeTodoEntry(todoPage.title,_curTodo,_curUid); 
                               todoPageModel.remove(_curIndex);
                           }
                           else {
                               todoPageModel.clearDone()
                               infoNoteDrawer.clear = false
                           }
                           infoNoteDrawer.close();
                       }
                   }
                   Controls.Button {
                       text: "Abort"
                       onClicked: { infoNoteDrawer.clear = false ; infoNoteDrawer.close() }
                       height: Kirigami.Settings.isMobile ? Kirigami.Units.iconSizes.large : undefined
                       width: Kirigami.Settings.isMobile ? Kirigami.Units.iconSizes.large * 2 : undefined
                   }
               }
            }
        }
    }
    
    Timer {
        id: autoSaveTimer
        interval: 5000
        onTriggered: saveChanged()
    }
    
}
