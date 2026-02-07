import QtQuick
import Quickshell
import Quickshell.Wayland

import "../../theme" as Theme

Variants {
    id: root
    model: Quickshell.screens

    default property list<PowerAction> actions

    property string fontFamily: "JetBrainsMono Nerd Font"
    property string centerIconText: ""
    property string layerNamespace: "quickshell:powermenu"

    property real outerRadius: 280
    property real innerRadius: 160
    property real gapDegrees: 6

    property bool open: false
    property bool quitting: false

    Component.onCompleted: open = true

    PanelWindow {
        id: win
        required property var modelData
        screen: modelData

        Theme.Tokens {
            id: tokens
        }

        Timer {
            id: quitTimer
            interval: tokens.durMed + 40
            repeat: false
            onTriggered: Qt.quit()
        }

        function closeAndQuit() {
            if (root.quitting)
                return;
            root.quitting = true;
            root.open = false;
            quitTimer.start();
        }

        anchors {
            top: true
            left: true
            right: true
            bottom: true
        }
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: root.layerNamespace
        WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

        property real progress: root.open ? 1 : 0
        Behavior on progress {
            NumberAnimation {
                duration: tokens.durMed
                easing.type: Easing.OutCubic
            }
        }

        Item {
            anchors.fill: parent
            opacity: win.progress
            visible: win.progress > 0.01
            enabled: visible

            FocusScope {
                anchors.fill: parent
                focus: root.open

                Keys.onPressed: ev => {
                    if (ev.key === Qt.Key_Escape) {
                        win.closeAndQuit();
                        ev.accepted = true;
                        return;
                    }
                    for (let i = 0; i < root.actions.length; i++) {
                        const a = root.actions[i];
                        if (a.key !== 0 && ev.key === a.key) {
                            a.exec();
                            win.closeAndQuit();
                            ev.accepted = true;
                            return;
                        }
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: Qt.rgba(0.06, 0.06, 0.09, 0.72)
                }

                MouseArea {
                    anchors.fill: parent
                    z: 0
                    onClicked: win.closeAndQuit()
                }

                DonutMenu {
                    z: 1
                    anchors.centerIn: parent
                    width: root.outerRadius * 2 + 160
                    height: width

                    actions: root.actions
                    fontFamily: root.fontFamily
                    centerIconText: root.centerIconText

                    outerRadius: root.outerRadius
                    innerRadius: root.innerRadius
                    gapDegrees: root.gapDegrees

                    progress: win.progress

                    onTriggered: action => {
                        action.exec();
                        win.closeAndQuit();
                    }
                }
            }
        }
    }
}
