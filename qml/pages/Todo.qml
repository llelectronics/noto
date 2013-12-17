import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.theme 1.0
import "../config.js" as DB

Page {
    id: todoPage
    property Item contextMenu

    property QtObject dataContainer: null
    property string todoTitleText: null

    Component.onCompleted: {
        if (todoTitleText != null) {
            todoPage.listHeaderTextField.text = todoTitleText
            console.log("Get Todos for " + todoTitleText + "...")
            DB.getTodo(todoTitleText);
        }
        //if (noteText != null) note.text = noteText
    }


    ListModel {
        id: todoModel
    }

    function addTodo(todo,status) {
        console.debug("Adding todo:" + todo + "with status:" + status)
        todoModel.append({"todo": todo, "status": status})
    }

    property TextField listHeaderTextField: null
    Component {
        id: listHeaderComponent
        TextField {
            id: todoTitle
            width: parent.width - 120
            anchors.left: parent.left
            anchors.leftMargin: 80
            placeholderText: "Title of Todo"
            Component.onCompleted: todoPage.listHeaderTextField = todoTitle
        }
    }

    SilicaListView {
        id: todoList
        width: parent.width
        height: parent.height
        model: todoModel
        anchors.top : parent.top
        anchors.topMargin: 20
        header: listHeaderComponent
        ViewPlaceholder {
            enabled: todoList.count == 0
            text: qsTr("Please insert a todo here")
        }
        PullDownMenu {
            MenuItem {
                text: "Save"
                onClicked: {
                    //DB.setTodo(todoTitle.text,todo.text,status)
                    for (var i = 0; i < todoModel.count; i++) {
                        console.debug("Save todo " + todoPage.listHeaderTextField.text + " with text: " + todoModel.get(i).todo + " and status:" + todoModel.get(i).status)
                        DB.setTodo(todoPage.listHeaderTextField.text,todoModel.get(i).todo,todoModel.get(i).status)
                    }
                    if (dataContainer != null) todoPage.dataContainer.addTodoTitle(todoPage.listHeaderTextField.text)
                }

            }
            MenuItem {
                text: "Insert Todo"
                onClicked: {
                    todoModel.append({ "todo": "", "status": 0})
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

            width: ListView.view.width
            height: menuOpen ? contextMenu.height + contentItem.height : contentItem.height

            function remove() {
                var removal = removalComponent.createObject(myListItem)
                ListView.remove.connect(removal.deleteAnimation.start)
                removal.execute(contentItem, "Deleting", function() { todoModel.remove(index) } )
                DB.removeTodoEntry(todoPage.listHeaderTextField.text,todo)
            }

            BackgroundItem {
                id: contentItem

                width: parent.width
                onPressAndHold: {
                    if (!contextMenu)
                        contextMenu = contextMenuComponent.createObject(notoList)
                    contextMenu.show(myListItem)
                }
                onClicked: {
                    console.log("Clicked " + todo)
                }


                TextField {
                    id: todoText
                    text: todo
                    placeholderText: "Enter new todo here"
                    anchors.left: parent.left
                    width: parent.width - todoStatus.width
                    height: todoStatus.height
                    anchors.leftMargin: 10
                    onTextChanged: {
                        todoModel.get(index).todo = text
                    }
                }
                Switch {
                    id: todoStatus
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: todoText.verticalCenter
                    checked: { if (status == 1) true
                        else false }
                    onCheckedChanged: {
                        if (todoModel.get(index).status == 0)  todoModel.get(index).status = 1
                        else todoModel.get(index).status = 0
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
                        onClicked: menu.parent.remove()
                    }
                }
            }
        }
    }

}
