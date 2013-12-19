/*
  Copyright (C) 2013 Leszek Lesner.
  Contact: Leszek Lesner <leszek.lesner@googlemail.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../config.js" as DB

Page {
    id: root

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
                text: "About"
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("About.qml"), {dataContainer: root})
                }
            }
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
            property Item contextMenu

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
                        onClicked: {
                            menu.parent.remove();
                        }
                    }
                }
            }
        }
    }
}




