import QtQuick

Item {
    id: root
    anchors.fill: parent
    clip: true

    function burst(x, y, color) {
        rippleComp.createObject(root, { cx: x, cy: y, c: color })
    }

    Component {
        id: rippleComp

        Item {
            id: r
            property real cx: 0
            property real cy: 0
            property color c: "#cba6f7"

            x: cx
            y: cy
            width: 1
            height: 1

            Rectangle {
                anchors.centerIn: parent
                width: 360
                height: 360
                radius: width / 2
                color: r.c
                opacity: 0.0
                scale: 0.10

                SequentialAnimation on opacity {
                    running: true
                    NumberAnimation { to: 0.22; duration: 90 }
                    NumberAnimation { to: 0.0; duration: 260 }
                    onFinished: r.destroy()
                }

                NumberAnimation on scale {
                    running: true
                    from: 0.10
                    to: 1.0
                    duration: 320
                    easing.type: Easing.OutCubic
                }
            }
        }
    }
}

