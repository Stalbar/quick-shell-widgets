import QtQuick
import QtQuick.Controls

import Quickshell
import Quickshell.Wayland

import Qt5Compat.GraphicalEffects
import "." as Launcher

PanelWindow {
    id: win
    required property var controller

    screen: controller.screen
    visible: false
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.namespace: "qs:launcher"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    property real openT: 0.0
    property real bloomPulse: 1.0

    Item {
        id: scene
        anchors.fill: parent
        opacity: 0.0
        scale: 0.985
        visible: win.visible
        focus: true

        Rectangle {
            anchors.fill: parent
            color: Launcher.Palette.scrim
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: Qt.rgba(0, 0, 0, 0.58)
                }
                GradientStop {
                    position: 1.0
                    color: Qt.rgba(0, 0, 0, 0.36)
                }
            }
        }

        NoiseOverlay {
            anchors.fill: parent
        }

        MouseArea {
            anchors.fill: parent
            onPressed: mouse => {
                const p = panel.mapFromItem(scene, mouse.x, mouse.y);
                const outside = (p.x < 0 || p.y < 0 || p.x > panel.width || p.y > panel.height);
                if (outside)
                    controller.hide();
            }
        }

        Item {
            id: panel
            anchors.centerIn: parent
            width: Math.min(980, parent.width * 0.78)
            height: Math.min(720, parent.height * 0.74)

            DropShadow {
                anchors.fill: bg
                source: bg
                horizontalOffset: 0
                verticalOffset: 26
                radius: 62
                samples: 91
                color: Qt.rgba(0, 0, 0, 0.70)
            }

            Glow {
                id: panelBloom
                anchors.fill: bg
                source: bg
                radius: 44
                samples: 91
                color: Launcher.Palette.glow
                // IMPORTANT: keep a binding; pulse via bloomPulse
                opacity: (0.15 + 0.55 * win.openT) * win.bloomPulse
            }

            // Pulse the multiplier (not panelBloom.opacity directly)
            NumberAnimation {
                target: win
                property: "bloomPulse"
                running: win.visible && win.openT > 0.2
                from: 0.85
                to: 1.15
                duration: 1600
                loops: Animation.Infinite
                easing.type: Easing.InOutSine
            }

            Rectangle {
                id: bg
                anchors.fill: parent
                radius: 28
                color: Launcher.Palette.acrylic
                border.width: 1
                border.color: Launcher.Palette.stroke

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 1
                    radius: parent.radius - 1
                    color: "transparent"
                    gradient: Gradient {
                        GradientStop {
                            position: 0.0
                            color: Qt.rgba(1, 1, 1, 0.10)
                        }
                        GradientStop {
                            position: 0.35
                            color: Qt.rgba(1, 1, 1, 0.03)
                        }
                        GradientStop {
                            position: 1.0
                            color: Qt.rgba(0, 0, 0, 0.10)
                        }
                    }
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    height: parent.height * 0.22
                    radius: parent.radius
                    color: "transparent"
                    gradient: Gradient {
                        GradientStop {
                            position: 0.0
                            color: Qt.rgba(Launcher.Palette.mauve.r, Launcher.Palette.mauve.g, Launcher.Palette.mauve.b, 0.10)
                        }
                        GradientStop {
                            position: 1.0
                            color: Qt.rgba(Launcher.Palette.blue.r, Launcher.Palette.blue.g, Launcher.Palette.blue.b, 0.00)
                        }
                    }
                    opacity: 0.65
                }
            }

            Item {
                anchors.fill: parent
                anchors.margins: 18

                AppLauncher {
                    id: launcher
                    anchors.fill: parent
                    controller: win.controller
                    onRequestClose: win.controller.hide()
                }
            }
        }
    }

    SequentialAnimation {
        id: showAnim
        ScriptAction {
            script: {
                win.visible = true;
                win.openT = 0.0;
                win.bloomPulse = 1.0;
                scene.opacity = 0.0;
                scene.scale = 0.985;
            }
        }
        ParallelAnimation {
            NumberAnimation {
                target: scene
                property: "opacity"
                to: 1.0
                duration: Launcher.Motion.durNormal
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: scene
                property: "scale"
                to: 1.0
                duration: Launcher.Motion.durLong
                easing.type: Easing.OutBack
            }
            NumberAnimation {
                target: win
                property: "openT"
                to: 1.0
                duration: 520
                easing.type: Easing.OutCubic
            }
        }
        ScriptAction {
            script: launcher.focusSearch()
        }
    }

    SequentialAnimation {
        id: hideAnim
        ParallelAnimation {
            NumberAnimation {
                target: win
                property: "openT"
                to: 0.0
                duration: Launcher.Motion.durFast
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: scene
                property: "opacity"
                to: 0.0
                duration: Launcher.Motion.durFast
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: scene
                property: "scale"
                to: 0.985
                duration: Launcher.Motion.durFast
                easing.type: Easing.OutCubic
            }
        }
        ScriptAction {
            script: win.visible = false
        }
    }

    Connections {
        target: controller
        function onOpenChanged() {
            if (controller.open) {
                hideAnim.stop();
                showAnim.restart();
            } else {
                showAnim.stop();
                hideAnim.restart();
            }
        }
    }
}
