import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects
import "." as Launcher

Item {
    id: root

    property var item: null
    property int itemIndex: -1
    property bool current: false
    property var controller: null

    signal activated(var item)

    implicitHeight: 88
    property bool hovered: false

    readonly property bool isCommand: !!item && (item.kind === "command" || item.kind === "action")
    readonly property bool isPinned: (!isCommand && item && item.id) ? Launcher.LauncherState.isPinned(String(item.id)) : false

    readonly property string uiFamily: (Launcher.Typography && Launcher.Typography.family !== undefined) ? String(Launcher.Typography.family) : Qt.application.font.family

    readonly property int titleSize: (Launcher.Typography && Launcher.Typography.itemTitle !== undefined) ? Number(Launcher.Typography.itemTitle) : 15

    readonly property int subSize: (Launcher.Typography && Launcher.Typography.itemSub !== undefined) ? Number(Launcher.Typography.itemSub) : 12

    Rectangle {
        id: card
        anchors.fill: parent
        radius: 18

        color: root.current ? Qt.rgba(Launcher.Palette.mauve.r, Launcher.Palette.mauve.g, Launcher.Palette.mauve.b, 0.20) : root.hovered ? Qt.rgba(1, 1, 1, 0.07) : Qt.rgba(1, 1, 1, 0.035)

        border.width: 1
        border.color: root.current ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(1, 1, 1, 0.09)

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

    Glow {
        anchors.fill: card
        source: card
        radius: root.current ? 24 : 0
        samples: 41
        color: Qt.rgba(Launcher.Palette.mauve.r, Launcher.Palette.mauve.g, Launcher.Palette.mauve.b, 0.35)
        visible: root.current
        opacity: 0.95
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        Rectangle {
            Layout.preferredWidth: 44
            Layout.preferredHeight: 44
            radius: 14
            color: Qt.rgba(1, 1, 1, root.current ? 0.10 : 0.06)
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, root.current ? 0.18 : 0.12)

            IconImage {
                anchors.centerIn: parent
                width: 30
                height: 30
                source: root.isCommand ? Quickshell.iconPath(root.item.icon || "system-run", "system-run") : (root.item ? Quickshell.iconPath(root.item.icon, "application-x-executable") : "")
                smooth: true
                mipmap: true
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Label {
                Layout.fillWidth: true
                text: root.isCommand ? (root.item.name || "") : (root.item ? (root.item.name || root.item.id || "") : "")
                elide: Text.ElideRight
                color: Launcher.Palette.text
                font.family: root.uiFamily
                font.pixelSize: root.titleSize
                font.weight: root.current ? 650 : 520
            }

            Label {
                Layout.fillWidth: true
                text: root.isCommand ? (root.item.subtitle || "") : (root.item ? (root.item.genericName || "") : "")
                visible: text.length > 0 && (root.isCommand || root.hovered)
                elide: Text.ElideRight
                color: Launcher.Palette.subtext0
                opacity: root.hovered ? 0.95 : 0.70
                font.family: root.uiFamily
                font.pixelSize: root.subSize
                Behavior on opacity {
                    NumberAnimation {
                        duration: Launcher.Motion.durNormal
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }

        Rectangle {
            visible: root.isPinned
            Layout.preferredWidth: 26
            Layout.preferredHeight: 26
            radius: 10
            color: Qt.rgba(1, 1, 1, 0.06)
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.14)

            IconImage {
                anchors.centerIn: parent
                width: 14
                height: 14
                source: Quickshell.iconPath("emblem-favorite", "starred")
                opacity: 0.95
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onEntered: root.hovered = true
        onExited: root.hovered = false

        onClicked: mouse => {
            if (!root.controller || !root.item)
                return;

            if (mouse.button === Qt.RightButton && !root.isCommand && root.item.id) {
                Launcher.LauncherState.togglePin(String(root.item.id));
                return;
            }

            root.controller.selectedIndex = root.itemIndex;
            root.activated(root.item);
        }

        onDoubleClicked: {
            if (!root.controller || !root.item)
                return;
            root.controller.selectedIndex = root.itemIndex;
            root.activated(root.item);
        }
    }
}
