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
import "Components"

Page {
    id: root
    allowedOrientations: defaultAllowedOrientations

    property int contentItemHeight: Theme.itemSizeSmall
    property int contentItemFontSize: Theme.fontSizeSmall

    function addNote(title,uid) {
        var contains = notoModel.contains(uid)
        if (!contains[0]) {
            notoModel.append({"title": title, "type": "note", "uid":uid})
        }
    }

    function updateNote(title,uid) {
        var contains = notoModel.contains(uid)
        //console.debug("[FirstPage] updateNote with uid: " + uid + " contains[0]: " + contains[0] + " contains[1]:" + contains[1])
        if (contains[0]) {
            notoModel.set(contains[1],{"title": title})
        }
    }

    function addTodoTitle(title) {
        if (!notoModel.containsTitle(title)) notoModel.append({"title": title, "type": "todo", "uid": ""})
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
    }



    PinchArea {
        width: parent.width
        height: parent.height

        onPinchUpdated: {
            // adjust content pos due to drag
            console.debug("previous X : " + pinch.previousCenter.x + " current X : " + pinch.center.x)
            console.debug("previous Y : " + pinch.previousCenter.y + " current Y : " + pinch.center.y)
            if (Math.floor(pinch.previousCenter.x) < Math.floor(pinch.center.x) && Math.floor(pinch.previousCenter.y) > Math.floor(pinch.center.y)) {
                //console.debug("Make everything bigger")
                contentItemHeight = Theme.itemSizeSmall
                contentItemFontSize = Theme.fontSizeSmall
            }
            else if (Math.floor(pinch.previousCenter.x) > Math.floor(pinch.center.x) && Math.floor(pinch.previousCenter.y) < Math.floor(pinch.center.y)) {
                //console.debug("Make everything smaller")
                contentItemHeight = Theme.itemSizeExtraSmall
                contentItemFontSize = Theme.fontSizeExtraSmall
            }
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
                    text: qsTr("Backup Manager")
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("BackupPage.qml"))
                    }
                }
                MenuItem {
                    text: "Add Note"
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("Note.qml"), {dataContainer: root, noteUid: 0})
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
                    removal.execute(contentItem, "Deleting", function() { if (type != "note") uid = 0; DB.remove(title,type,uid); notoModel.remove(index); } )
                }

                BackgroundItem {
                    id: contentItem

                    height: contentItemHeight

                    width: parent.width
                    onPressAndHold: {
                        if (!contextMenu)
                            contextMenu = contextMenuComponent.createObject(notoList)
                        contextMenu.show(myListItem)
                    }
                    onClicked: {
                        //console.log("Clicked " + title)
                        if (type === "note") {
                            pageStack.push(Qt.resolvedUrl("Note.qml"), {noteTitleText: title, noteText: DB.getText(title,uid), noteUid: uid} )
                            //console.debug("Text:" + DB.getText(title,uid))
                        }
                        if (type === "todo") {
                            pageStack.push(Qt.resolvedUrl("Todo.qml"), {todoTitleText: title} )
                            //console.debug("Todo:" + DB.getTodo(title)[0])
                        }
                    }
                    Image {
                        id: typeIcon
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.paddingSmall
                        source: {
                            if (type === "note") "image://theme/icon-l-copy"
                            else "image://theme/icon-m-levels"
                        }
                        height: parent.height
                        width: height
                    }
                    Label {
                        id: typeTitle
                        text: title
                        anchors.left: typeIcon.right
                        anchors.leftMargin: Theme.paddingMedium
                        anchors.verticalCenter: parent.verticalCenter
                        font.capitalization: Font.Capitalize
                        truncationMode: TruncationMode.Elide
                        elide: Text.ElideRight
                        color: contentItem.down || menuOpen ? Theme.highlightColor : Theme.primaryColor
                        font.pixelSize: contentItemFontSize
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
}




