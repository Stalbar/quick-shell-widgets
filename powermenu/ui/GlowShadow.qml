import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root
    required property Item sourceItem

    property color glowColor: "#cba6f7"
    property real glowOpacity: 0.25
    property int glowRadius: 26

    property int shadowRadius: 56
    property real shadowOpacity: 0.55
    property int shadowYOffset: 16

    x: sourceItem ? sourceItem.x : 0
    y: sourceItem ? sourceItem.y : 0
    width: sourceItem ? sourceItem.width : 0
    height: sourceItem ? sourceItem.height : 0

    DropShadow {
        anchors.fill: parent
        source: root.sourceItem
        horizontalOffset: 0
        verticalOffset: root.shadowYOffset
        radius: root.shadowRadius
        samples: 64
        color: Qt.rgba(0, 0, 0, root.shadowOpacity)
    }

    Glow {
        anchors.fill: parent
        source: root.sourceItem
        radius: root.glowRadius
        spread: 0.18
        color: root.glowColor
        opacity: root.glowOpacity
    }
}

