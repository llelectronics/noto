import QtQuick 2.0
import Sailfish.Silica 1.0
import "../config.js" as DB

Page {
    id: todoPage

    property QtObject dataContainer: null
    property string todoTitleText

    property bool firstLoad: false
    property bool todoEdited: false

    showNavigationIndicator: mainWindow.applicationActive ? true : false

    Component.onCompleted: {
        if (todoTitleText != null) {
            todoPage.listHeaderTextField.text = todoTitleText
            todoPage.listHeaderTextField.forceActiveFocus();
            //console.log("Get Todos for " + todoTitleText + "...")
            firstLoad = true
            DB.getTodo(todoTitleText);

        }
        //if (noteText != null) note.text = noteText
    }

    function setFirstLoadFalse() {
        firstLoad = false;
    }



    onStatusChanged: {
        if (status === PageStatus.Deactivating) {
            //console.log("TodoEdited:" + todoEdited)
            if (todoPage.listHeaderTextField.text.length > 0 && todoEdited === true) {
                for (var i = 0; i < todoModel.count; i++) {
                    //console.debug("Save todo " + todoPage.listHeaderTextField.text + " with text: " + todoModel.get(i).todo + " and status:" + todoModel.get(i).status + " and uid:" + todoModel.get(i).uid) // DEBUG
                    DB.setTodo(todoPage.listHeaderTextField.text,todoModel.get(i).todo,todoModel.get(i).status,todoModel.get(i).uid)
                }
                if (dataContainer != null) todoPage.dataContainer.addTodoTitle(todoPage.listHeaderTextField.text)
            }
        }
    }

    ListModel {
        id: todoModel
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
                width: parent.width - 120
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
                text: "Insert Todo"
                onClicked: {
                    todoModel.append({ "todo": "", "status": 0, "uid" : DB.getUniqueId()});
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
//                onPressAndHold: {
//                    if (!contextMenu)
//                        contextMenu = contextMenuComponent.createObject(notoList)
//                    contextMenu.show(myListItem)
//                }
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
                    onTextChanged: {
                        if (firstLoad === true) { todoEdited = false } else { todoEdited = true }
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

                    onClicked: firstLoad = false

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
                        }
                        else {
                            todoModel.get(index).status = 0
                            todoList.move(index,0)
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
                        onClicked: menu.parent.remove(1);
                    }
                }
            }
        }
    }

}
