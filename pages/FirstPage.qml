import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.theme 1.0
import "../config.js" as DB

Page {
    id: root
    property Item contextMenu

    function addNote(title) {
        notoModel.append({"title": title, "type": "note"})
    }

    function addTodoTitle(title) {
        notoModel.append({"title": title, "type": "todo"})
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
        console.log("Get Notes...")
        DB.getNotes();
        console.log("Get Todos...")
        DB.getTodos();
    }

    ListModel {
        id: notoModel
    }

    // Place our content in a Column.  The PageHeader is always placed at the top
    // of the page, followed by our content.
    SilicaListView {
        id: notoList
        width: root.width
        height: root.height
        anchors.top: parent.top
        model: notoModel
        header: PageHeader { title: "Noto" }
        ViewPlaceholder {
            enabled: notoList.count == 0
            text: qsTr("Please create a note or todo")
        }
        PullDownMenu {
            MenuItem {
                text: "Add Note"
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("Note.qml"), {dataContainer: root})
                }
            }
            MenuItem {
                text: "Add Todo"
                onClicked: pageStack.push(Qt.resolvedUrl("Todo.qml"),{dataContainer: root})
            }
        }
        PushUpMenu {
            spacing: Theme.paddingLarge
            MenuItem {
                text: qsTr("Return to Top")
                onClicked: notoList.scrollToTop()
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
                removal.execute(contentItem, "Deleting", function() { notoModel.remove(index) } )
                DB.remove(title,type)
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
                    console.log("Clicked " + title)
                    if (type === "note") {
                        pageStack.push(Qt.resolvedUrl("Note.qml"), {noteTitleText: title, noteText: DB.getText(title)} )
                        console.debug("Text:" + DB.getText(title))
                    }
                    if (type === "todo") {
                        pageStack.push(Qt.resolvedUrl("Todo.qml"), {todoTitleText: title} )
                        //console.debug("Todo:" + DB.getTodo(title)[0])
                    }
                }

                Label {
                    x: Theme.paddingLarge
                    text: title
                    anchors.verticalCenter: parent.verticalCenter
                    font.capitalization: Font.Capitalize
                    color: contentItem.down || menuOpen ? Theme.highlightColor : Theme.primaryColor
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

