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


Page {
    id: page
    allowedOrientations: defaultAllowedOrientations


    Image {
        id: logo
        source: "noto.png"
        anchors.horizontalCenter: parent.horizontalCenter
        y: page.isPortrait ? 200 : 100
    }

    Label {
        id: appName
        anchors.horizontalCenter: parent.horizontalCenter
        y: page.isPortrait ? 320 : 220
        font.bold: true
        text: "Noto 1.8"
    }
    Text {
        id: desc
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: appName.bottom
        anchors.topMargin: 20
        text: "Simple note and todo taking application"
        color: "white"
    }
    Text {
        id: copyright
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: desc.bottom
        anchors.topMargin: 20
        text: "Copyright: Leszek Lesner <br />License: BSD (3-clause)"
        color: "white"
    }
    Button {
        id: homepage
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: copyright.bottom
        anchors.topMargin: 20
        text: "<a href=\"https://github.com/llelectronics/noto\">https://github.com/llelectronics/noto</a>"
        onClicked: {
            Qt.openUrlExternally("https://github.com/llelectronics/noto")
        }
    }

}





