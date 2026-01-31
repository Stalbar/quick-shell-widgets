import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

ColumnLayout {
    id: root

    property string label: ""
    property string value: ""
    property color accent: "#89b4fa"
    property string fontFamily: ""
    property real percentage: -1
    property var theme
    property bool isElide: false

    spacing: 6
    Layout.fillWidth: true

    property string shownValue: ""
    property real fade: 1
    property real slide: 0

    onValueChanged: {
        if (shownValue === "") {
            shownValue = value;
            fade = 1;
            slide = 0;
            return;
        }

        if (value === shownValue)
            return;
        fade = 0;
        slide = -6;
        swapTimer.start();
    }

    Timer {
        id: swapTimer
        interval: 90
        repeat: false
        onTriggered: {
            root.shownValue = root.value;
            root.fade = 1;
            root.slide = 0;
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 12

        Text {
            text: root.label
            color: root.accent
            font.pixelSize: 16
            font.bold: true
            font.family: root.fontFamily

            Layout.preferredWidth: 100
            Layout.minimumWidth: 35
            Layout.maximumWidth: 220
            Layout.fillWidth: false

            elide: Text.ElideRight
        }

        Item {
            Layout.fillWidth: true
            height: valueText.implicitHeight
            clip: true

            Rectangle {
                id: skeleton
                anchors.fill: parent
                radius: 8
                visible: (root.shownValue === "" && root.value === "")
                color: Qt.rgba(1, 1, 1, 0.05)
                clip: true

                property real shimmerX: -shimmer.width

                Rectangle {
                    id: shimmer
                    width: parent.width * 0.45
                    height: parent.height
                    radius: 8
                    x: skeleton.shimmerX
                    gradient: Gradient {
                        GradientStop {
                            position: 0.0
                            color: Qt.rgba(1, 1, 1, 0.00)
                        }
                        GradientStop {
                            position: 0.5
                            color: Qt.rgba(1, 1, 1, 0.10)
                        }
                        GradientStop {
                            position: 1.0
                            color: Qt.rgba(1, 1, 1, 0.00)
                        }
                    }
                    SequentialAnimation on x {
                        running: skeleton.visible
                        loops: Animation.Infinite

                        NumberAnimation {
                            to: -shimmer.width
                            duration: 0
                        }
                        NumberAnimation {
                            to: skeleton.width + shimmer.width
                            duration: 1100
                            easing.type: Easing.InOutSine
                        }
                    }
                    Component.onCompleted: skeleton.shimmerX = -shimmer.width
                    onWidthChanged: skeleton.shimmerX = -shimmer.width
                    onVisibleChanged: if (visible)
                        skeleton.shimmerX = -shimmer.width
                }
            }
            Text {
                id: valueText
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width                 // <- important
                horizontalAlignment: Text.AlignRight
                text: root.shownValue !== "" ? root.shownValue : (root.value !== "" ? root.value : "...")
                color: theme.text
                font.pixelSize: 16
                font.family: root.fontFamily

                elide: Text.ElideRight              // <- always safe
                wrapMode: Text.NoWrap
                opacity: root.fade
                y: root.slide

                Behavior on opacity {
                    NumberAnimation {
                        duration: theme.durMed
                        easing.type: theme.easeOut
                    }
                }
                Behavior on y {
                    NumberAnimation {
                        duration: theme.durMed
                        easing.type: theme.easeOut
                    }
                }
            }
        }
    }
    Item {
        visible: root.percentage >= 0
        Layout.fillWidth: true
        height: visible ? 10 : 0

        Rectangle {
            id: track
            anchors.fill: parent
            radius: height / 2
            color: theme.surface0
            opacity: 0.92
            clip: true

            Rectangle {
                id: fill
                width: Math.max(height, (parent.width * Math.max(0, Math.min(100, root.percentage))) / 100)
                height: parent.height
                radius: height / 2
                color: root.accent
                Rectangle {
                    width: parent.width
                    height: parent.height
                    radius: parent.radius
                    opacity: 0.22
                    gradient: Gradient {
                        GradientStop {
                            position: 0.0
                            color: Qt.rgba(1, 1, 1, 0.22)
                        }
                        GradientStop {
                            position: 1.0
                            color: Qt.rgba(1, 1, 1, 0.02)
                        }
                    }
                }

                Behavior on width {
                    NumberAnimation {
                        duration: theme.durBar
                        easing.type: theme.easeOut
                    }
                }
            }
        }
    }
}
