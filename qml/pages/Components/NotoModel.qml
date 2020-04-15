import QtQuick 2.0

ListModel {
    id: notoModel

    function contains(uid) {
        for (var i=0; i<count; i++) {
            if (get(i).uid == uid)  {
                return [true, i];
            }
        }
        return [false, i];
    }
    function containsTitle(title) {
        for (var i=0; i<count; i++) {
            if (get(i).title == title)  {
                return true;
            }
        }
        return false;
    }
}
