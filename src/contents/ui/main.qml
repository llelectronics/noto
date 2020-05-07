import QtQuick 2.1
import org.kde.kirigami 2.4 as Kirigami
import QtQuick.Controls 2.0 as Controls

Kirigami.ApplicationWindow {
    id: mainWindow

    title: "Noto"
    
    property Item firstPage
    property string version: "1.0"

    pageStack.initialPage: Component {
        FirstPage {
            id: firstPage

            Component.onCompleted: mainWindow.firstPage = firstPage
        }
    }

}
