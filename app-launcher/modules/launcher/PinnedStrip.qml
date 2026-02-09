import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell
import Quickshell.Widgets

import "." as Launcher

Item {
    id: root

    required property var controller
    property var entries: []
    signal launch(var entry)

    readonly property bool hasPins: entries && entries.length > 0

    readonly property string uiFamily: (Launcher.Typography && Launcher.Typography.family !== undefined) ? String(Launcher.Typography.family) : Qt.application.font.family

    readonly property int titleSize: (Launcher.Typography && Launcher.Typography.itemSub !== undefined) ? Number(Launcher.Typography.itemSub) : 12

    readonly property int chipSize: (Launcher.Typography && Launcher.Typography.itemSub !== undefined) ? Number(Launcher.Typography.itemSub) : 12

    implicitHeight: hasPins ? 64 : 0
    visible: hasPins

    Rectangle {
        anchors.fill: parent
        radius: 18
        color: Qt.rgba(1, 1, 1, 0.03)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.08)
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        RowLayout {
            Layout.preferredWidth: 84
            Layout.alignment: Qt.AlignVCenter
            spacing: 8

            IconImage {
                Layout.preferredWidth: 16
                Layout.preferredHeight: 16
                source: Quickshell.iconPath("emblem-favorite", "starred")
                opacity: 0.9
            }

            Label {
                text: "Pinned"
                color: Launcher.Palette.subtext0
                opacity: 0.95
                font.family: root.uiFamily
                font.pixelSize: root.titleSize
                font.weight: 650
            }
        }

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            contentWidth: row.implicitWidth
            contentHeight: height
            interactive: contentWidth > width

            Row {
                id: row
                height: parent.height
                spacing: 10

                Repeater {
                    model: root.entries

                    delegate: Item {
                        id: pill
                        height: parent.height
                        width: 190

                        property var entry: modelData

                        Rectangle {
                            id: bg
                            anchors.fill: parent
                            radius: 16
                            color: Qt.rgba(1, 1, 1, 0.045)
                            border.width: 1
                            border.color: Qt.rgba(1, 1, 1, 0.10)

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
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10

                            Rectangle {
                                Layout.preferredWidth: 36
                                Layout.preferredHeight: 36
                                radius: 12
                                color: Qt.rgba(1, 1, 1, 0.06)
                                border.width: 1
                                border.color: Qt.rgba(1, 1, 1, 0.12)

                                IconImage {
                                    anchors.centerIn: parent
                                    width: 22
                                    height: 22
                                    source: pill.entry ? Quickshell.iconPath(pill.entry.icon, "application-x-executable") : ""
                                    smooth: true
                                    mipmap: true
                                }
                            }

                            Label {
                                Layout.fillWidth: true
                                text: pill.entry ? (pill.entry.name || pill.entry.id || "") : ""
                                elide: Text.ElideRight
                                color: Launcher.Palette.text
                                font.family: root.uiFamily
                                font.pixelSize: root.chipSize
                                font.weight: 600
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true

                            onEntered: {
                                bg.color = Qt.rgba(1, 1, 1, 0.07);
                                bg.border.color = Qt.rgba(1, 1, 1, 0.16);
                            }
                            onExited: {
                                bg.color = Qt.rgba(1, 1, 1, 0.045);
                                bg.border.color = Qt.rgba(1, 1, 1, 0.10);
                            }

                            onClicked: {
                                if (pill.entry)
                                    root.launch(pill.entry);
                            }
                        }
                    }
                }
            }
        }
    }
}
