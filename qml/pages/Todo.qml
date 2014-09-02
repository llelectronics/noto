import QtQuick 2.0
import Sailfish.Silica 1.0
import "../config.js" as DB

Page {
    id: todoPage
    allowedOrientations: Orientation.All

    property QtObject dataContainer: null
    property string todoTitleText

    property bool firstLoad: false
    property bool todoEdited: false

    //property int indexChanged: -1

    showNavigationIndicator: mainWindow.applicationActive ? true : false

    Component.onCompleted: {
        if (todoTitleText != null) {
            //console.log("Get Todos for " + todoTitleText + "...")
            firstLoad = true
            if (todoTitleText != "") {
                DB.getTodo(todoTitleText);
                // Renaming of todolist is not supported by database
                listHeaderTextField.readOnly = true;
                todoPage.listHeaderTextField.text = todoTitleText
            }
            else {
                todoPage.listHeaderTextField.forceActiveFocus();
            }

        }
        //if (noteText != null) note.text = noteText
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
        if (todoPage.listHeaderTextField.text.length > 0 && todoEdited === true) {
            if (indexChanged.count == 0) { // A fallback when index can not be changed. This is much slower then the usual save
                for (var i = 0; i < todoModel.count; i++) {
                    console.debug("Save todo " + todoPage.listHeaderTextField.text + " with text: " + todoModel.get(i).todo + " and status:" + todoModel.get(i).status + " and uid:" + todoModel.get(i).uid) // DEBUG
                    DB.setTodo(todoPage.listHeaderTextField.text,todoModel.get(i).todo,todoModel.get(i).status,todoModel.get(i).uid)
                }
            }
            else {
                for (var i = 0; i < indexChanged.count; i++) {
                    console.log("Saving todo at " + indexChanged.get(i).idx)
                    DB.setTodo(todoPage.listHeaderTextField.text,todoModel.get(indexChanged.get(i).idx).todo,todoModel.get(indexChanged.get(i).idx).status,todoModel.get(indexChanged.get(i).idx).uid)
                    // Don't forget to set indexChanged to -1 to not mess up future saving
                }
                indexChanged.clear()
            }
            if (dataContainer != null) todoPage.dataContainer.addTodoTitle(todoPage.listHeaderTextField.text)
            todoEdited = false
        }
    }

    onStatusChanged: {
        if (status === PageStatus.Deactivating) {
            saveChanged()
        }
    }

    RemorsePopup {
        id: remorse
    }

    ListModel {
        id: todoModel

        function clearDone() {
            for (var i=count-1; i>0; i--) {
                console.debug("[Todo.qml] Todo: " + get(i).todo + " has status: " + get(i).status)
                if (get(i).status == 1)  { // type transformation is intended here
                    //console.log("[Todo.qml] Remove done task at index: " + i);
                    DB.removeTodoEntry(todoPage.listHeaderTextField.text,todoModel.get(i).todo,todoModel.get(i).uid) // Remove from database
                    remove(i); // Remove visually
                }
            }
        }
    }

    function addTodo(todo,status,uid) {
        //console.debug("Adding todo:" + todo + "with status:" + status + " and uid:" + uid) // DEBUG
        todoModel.append({"todo": todo, "status": status, "uid": uid})
        if (status === 0) todoList.move(todoList.count-1, 0);
        if (firstLoad === true) { todoEdited = false } else { todoEdited = true }
        //console.debug("addtodo todoedited=" + todoEdited)
    }

    property TextField listHeaderTextField: null
    Component {
        id: listHeaderComponent
        PageHeader {
            TextField {
                id: todoTitle
                width: parent.width - 160
                anchors.left: parent.left
                anchors.leftMargin: 80
                anchors.top: parent.top
                anchors.topMargin: 25
                placeholderText: "Title of Todo"
                Component.onCompleted: todoPage.listHeaderTextField = todoTitle
                focus: true
                font.pixelSize: mainWindow.applicationActive ? Theme.fontSizeMedium : Theme.fontSizeHuge
                color: mainWindow.applicationActive ? Theme.primaryColor : Theme.highlightColor
                onTextChanged: {
                    if (firstLoad === true) { todoEdited = false } else { todoEdited = true }
                    //console.debug("onTextChanged listHeader todoedited=" + todoEdited)
                }
                Keys.onEnterPressed: {
                    todoModel.append({ "todo": "", "status": 0, "uid" : DB.getUniqueId()});
                }
                Keys.onReturnPressed: {
                    todoModel.append({ "todo": "", "status": 0, "uid" : DB.getUniqueId()});
                }
                onClicked: firstLoad = false
            }
        }
    }

    SilicaListView {
        id: todoList
        width: parent.width
        height: parent.height
        model: todoModel
        anchors.top : parent.top
        //anchors.topMargin: 10
        header: listHeaderComponent

        function move(sourceIndex,targetIndex) {
            if(targetIndex >= 0 && targetIndex < todoModel.count){
                todoModel.move(sourceIndex, targetIndex, 1)
            }
        }


        ViewPlaceholder {
            enabled: todoList.count == 0
            text: qsTr("Please insert a todo here")
        }
        PullDownMenu {
            visible: mainWindow.applicationActive ? true : false
            MenuItem {
                text: "Clear done tasks"
                onClicked: {
                    remorse.execute("Clearing done tasks", function() { todoModel.clearDone() })
                    //todoModel.clearDone();
                }
            }
            MenuItem {
                text: "Save"
                onClicked: {
                    //DB.setTodo(todoTitle.text,todo.text,status)
                    for (var i = 0; i < todoModel.count; i++) {
//                        console.debug("Save todo " + todoPage.listHeaderTextField.text + " with text: " + todoModel.get(i).todo + " and status:" + todoModel.get(i).status)
                        DB.setTodo(todoPage.listHeaderTextField.text,todoModel.get(i).todo,todoModel.get(i).status,todoModel.get(i).uid)
                    }
                    if (dataContainer != null) todoPage.dataContainer.addTodoTitle(todoPage.listHeaderTextField.text)
                    todoEdited = false
                }

            }
            MenuItem {
                text: "Insert task"
                onClicked: {
                    if (firstLoad == true) firstLoad = false;
                    todoModel.append({ "todo": "", "status": 0, "uid" : DB.getUniqueId()});
                    autoSaveTimer.restart();
                }

            }
        }
        PushUpMenu {
            spacing: Theme.paddingLarge
            MenuItem {
                text: qsTr("Return to Top")
                onClicked: todoList.scrollToTop()
            }
        }
        VerticalScrollDecorator {}

        delegate: Item {
            id: myListItem
            property bool menuOpen: contextMenu != null && contextMenu.parent === myListItem
            property int myIndex: index
            property Item contextMenu

            width: ListView.view.width
            height: menuOpen ? contextMenu.height + contentItem.height : contentItem.height

            function remove() {
                var removal = removalComponent.createObject(myListItem)
                ListView.remove.connect(removal.deleteAnimation.start)
                removal.execute(contentItem, "Deleting", function() { DB.removeTodoEntry(todoPage.listHeaderTextField.text,todo,uid) ; todoModel.remove(index) } )
            }

            ListView.onAdd: {
                todoText.forceActiveFocus();
            }

            //BackgroundItem {
            FocusScope {
                id: contentItem

                width: parent.width
                height: childrenRect.height
//                onClicked: {
//                    console.log("Clicked " + todo)
//                }

                TextField {
                    id: todoText
                    text: todo
                    placeholderText: "Enter new todo here"
                    anchors.left: parent.left
                    width: parent.width - todoStatus.width
                    height: mainWindow.applicationActive ? todoStatus.height + Theme.paddingMedium : todoStatus.height + Theme.paddingLarge
                    anchors.leftMargin: 10
                    focus: true
                    font.pixelSize: mainWindow.applicationActive ? Theme.fontSizeSmall : Theme.fontSizeHuge

                    color: {
                        if (status == 0) return "white"
                        else return "gray"
                    }
                    readOnly: {
                        if (status == 0) return false
                        else return true
                    }
                    onTextChanged: {
                        if (firstLoad === true) { todoEdited = false; indexChanged.clear() }
                        else {
                            todoEdited = true
                            indexChanged.add(myListItem.myIndex);
                            autoSaveTimer.restart()
                        }
                        //console.debug("todoText textchanged todoedited=" + todoEdited)
                        todoModel.get(index).todo = text
                    }
                    Keys.onEnterPressed: {
                        todoModel.append({ "todo": "", "status": 0, "uid": DB.getUniqueId()});
                    }
                    Keys.onReturnPressed: {
                        todoModel.append({ "todo": "", "status": 0, "uid": DB.getUniqueId()});
                    }
                    onFocusChanged: if (focus == false) {
                                        if (todoModel.get(index).status != 0)  {
                                            todoList.move(index,todoModel.count-1);
                                        }
                                        else {
                                            todoList.move(index,0)
                                        }
                                    }

                    onClicked: if (! readOnly) firstLoad = false

                    onPressAndHold: {
                        if (!contextMenu && todoText.readOnly)
                            contextMenu = contextMenuComponent.createObject(todoList)
                        contextMenu.show(myListItem)
                    }

                }
                Switch {
                    id: todoStatus
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: todoText.verticalCenter
                    width: 72
                    height: mainWindow.applicationActive ? 77 : 128
                    checked: { if (status == 1) true
                        else false }
                    onClicked: {
                        firstLoad = false
                        todoEdited = true
                        if (todoModel.get(index).status == 0)  {
                            todoModel.get(index).status = 1;
                            todoList.move(index,todoModel.count-1);
                            indexChanged.add(todoModel.count-1);
                            saveChanged();
                        }
                        else {
                            todoModel.get(index).status = 0;
                            todoList.move(index,0);
                            indexChanged.add(0);
                            saveChanged();
                        }
//                        console.log("Status changed to: " + todoModel.get(index).status + " todoEdited:" + todoEdited) // DEBUG
                    }
                    onPressAndHold: {
                        if (!contextMenu)
                            contextMenu = contextMenuComponent.createObject(todoList)
                        contextMenu.show(myListItem)
                    }
                }
            }

            Component {
                id: removalComponent
                RemorseItem {
                    property QtObject deleteAnimation: SequentialAnimation {
                        PropertyAction { target: myListItem; property: "ListView.delayRemove"; value: true }
                        NumberAnimation {
                            target: myListItem
                            properties: "height,opacity"; to: 0; duration: 300
                            easing.type: Easing.InOutQuad
                        }
                        PropertyAction { target: myListItem; property: "ListView.delayRemove"; value: false }
                    }
                    onCanceled: destroy()
                }
            }
            Component {
                id: contextMenuComponent
                ContextMenu {
                    id: menu
                    MenuItem {
                        text: "Delete"
                        onClicked: {
                            menu.parent.remove(1);
                        }
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
