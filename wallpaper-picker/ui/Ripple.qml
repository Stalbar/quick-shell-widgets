import QtQuick

Item {
    id: root
    anchors.fill: parent
    clip: true

    property color rippleColor: Qt.rgba(1, 1, 1, 0.18)
    property point origin: Qt.point(width/2, height/2)

    function burst(x, y) {
        origin = Qt.point(x, y);
        wave.restart();
    }

    Rectangle {
        id: circle
        width: 0
        height: 0
        radius: width / 2
        x: root.origin.x - width/2
        y: root.origin.y - height/2
        color: root.rippleColor
        opacity: 0.0
    }

    SequentialAnimation {
        id: wave
        ScriptAction { script: { circle.width = 0; circle.height = 0; circle.opacity = 0.0; } }
        ParallelAnimation {
            NumberAnimation { target: circle; property: "opacity"; to: 1.0; duration: 80 }
            NumberAnimation { target: circle; property: "width"; to: Math.max(root.width, root.height) * 1.8; duration: 260; easing.type: Easing.OutCubic }
            NumberAnimation { target: circle; property: "height"; to: Math.max(root.width, root.height) * 1.8; duration: 260; easing.type: Easing.OutCubic }
        }
        NumberAnimation { target: circle; property: "opacity"; to: 0.0; duration: 220; easing.type: Easing.OutCubic }
    }
}
