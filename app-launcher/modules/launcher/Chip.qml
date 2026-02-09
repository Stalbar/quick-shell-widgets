import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell
import Quickshell.Widgets
import "." as Launcher

Item {
    id: root
    property string text: ""
    property string icon: ""
    property bool selected: false
    signal clicked

    implicitHeight: 34
    implicitWidth: row.implicitWidth + 18

    readonly property string uiFamily: (Launcher.Typography && Launcher.Typography.family !== undefined) ? String(Launcher.Typography.family) : Qt.application.font.family

    readonly property int uiSize: (Launcher.Typography && Launcher.Typography.itemSub !== undefined) ? Number(Launcher.Typography.itemSub) : 13

    Rectangle {
        anchors.fill: parent
        radius: 999
        color: root.selected ? Qt.rgba(Launcher.Palette.mauve.r, Launcher.Palette.mauve.g, Launcher.Palette.mauve.b, 0.22) : Qt.rgba(1, 1, 1, 0.05)
        border.width: 1
        border.color: root.selected ? Qt.rgba(1, 1, 1, 0.22) : Qt.rgba(1, 1, 1, 0.12)

        Behavior on color {
            ColorAnimation {
                duration: Launcher.Motion.durNormal
                easing.type: Easing.OutCubic
            }
        }
        Behavior on border.color {
            ColorAnimation {
                duration: Launcher.Motion.durNormal
                easing.type: Easing.OutCubic
            }
        }
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 8

        IconImage {
            Layout.preferredWidth: 16
            Layout.preferredHeight: 16
            source: Quickshell.iconPath(root.icon || "", "")
            opacity: root.selected ? 0.95 : 0.85
        }

        Label {
            text: root.text
            color: Launcher.Palette.text
            opacity: root.selected ? 1.0 : 0.92
            font.family: root.uiFamily
            font.pixelSize: root.uiSize
            font.weight: root.selected ? 650 : 520
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
    }
}
