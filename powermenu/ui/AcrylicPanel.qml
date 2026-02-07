import QtQuick
import "../theme" as Theme

Item {
    id: root

    Theme.Tokens { id: tokens }

    property real opacityBase: 0.62
    property color tint: Qt.rgba(0.10, 0.10, 0.16, opacityBase)
    property color borderColor: Qt.rgba(1, 1, 1, 0.10)
    property int radius: tokens.radiusLg

    property bool showHighlight: true

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: root.tint
        border.width: 1
        border.color: root.borderColor
    }

    Rectangle {
        visible: root.showHighlight
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: Math.max(2, parent.height * 0.18)
        radius: root.radius
        color: Qt.rgba(1, 1, 1, 0.05)
        clip: true
    }

    Noise {
        anchors.fill: parent
        strength: 0.0
        scale: 1.0
    }
}

