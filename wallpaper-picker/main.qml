import QtQuick.Layouts
import Quickshell
import QtQuick
import Quickshell.Wayland
import Quickshell.Io
import Qt5Compat.GraphicalEffects

PanelWindow {
    id: pickerRoot
    anchors {
        bottom: true
        left: true
        right: true
    }
    margins {
        bottom: -200
        left: 388
        right: 388
    }
    implicitHeight: 220
    color: "transparent"
    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.namespace: "wallpaper_picker"
    WlrLayershell.exclusionMode: WlrLayershell.None
    WlrLayershell.keyboardFocus: WlrLayershell.OnDemand
    focusable: true
    Behavior on margins.bottom {
        NumberAnimation {
            duration: 600
            easing.type: Easing.OutCubic
        }
    }
    Component.onCompleted: {
        pickerRoot.margins.bottom = 0;
    }
    Rectangle {
        id: bgContainer
        anchors.fill: parent
        anchors.topMargin: 200
        color: "#e6b4befe"
        radius: 20
        bottomLeftRadius: 0
        bottomRightRadius: 0
        border.width: 2
        border.color: "#74c7ec"
        Item {
            focus: true
            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape) {
                    pickerRoot.margins.bottom = -200;
                    const quitTimer = Qt.createQmlObject('import QtQuick; Timer { interval: 600; onTriggered: Qt.quit() }', pickerRoot);
                    quitTimer.start();
                }
            }
        }
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 0
            anchors.topMargin: -120
            spacing: 10
            ListView {
                id: wallpaperView
                property int hoveredIndex: -1
                Layout.fillWidth: true
                Layout.fillHeight: true
                orientation: ListView.Horizontal
                spacing: 40
                clip: false
                leftMargin: 20
                rightMargin: 20
                interactive: true
                flickableDirection: Flickable.HorizontalFlick
                maximumFlickVelocity: 2500
                flickDeceleration: 1500
                boundsBehavior: Flickable.StopAtBounds
                model: ListModel {
                    id: wallpaperModel
                }
                WheelHandler {
                    id: wheelHook
                    target: wallpaperView
                    rotationScale: 20.0
                    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                    onWheel: event => {
                        let delta = event.angleDelta.y * -0.5;
                        let newX = wallpaperView.contentX + delta;
                        let minX = 0;
                        let maxX = wallpaperView.contentWidth - wallpaperView.width;
                        wallpaperView.contentX = Math.max(minX, Math.min(newX, maxX));
                    }
                }
                delegate: Rectangle {
                    id: delegateRoot
                    width: 342
                    height: 140
                    radius: 12
                    color: "#1e1e2e"
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 10
                    Image {
                        id: mainImage
                        anchors.fill: parent
                        anchors.margins: 4
                        source: "file://" + model.path
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: Rectangle {
                                width: mainImage.width;
                                height: mainImage.height;
                                radius: delegateRoot.radius - 4
                            } 
                        }
                    }
                    opacity: 0
                    scale: 0.8
                    Behavior on scale {
                        NumberAnimation {
                            duration: 350
                            easing.type: Easing.OutQuint
                        }
                    }
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 350
                        }
                    }
                    Behavior on border.color {
                        ColorAnimation {
                            duration: 200
                        }
                    }
                    Component.onCompleted: {
                        const entryAnim = Qt.createQmlObject(`
                            import QtQuick;
                            SequentialAnimation {
                                PauseAnimation { duration: ${500 + index * 100} }
                                ParallelAnimation {
                                    NumberAnimation { target: delegateRoot; property: "opacity"; to: 1.0; duration: 300 }
                                    NumberAnimation { target: delegateRoot; property: "scale"; to: 1.0; duration: 300; easing.type: Easing.OutCubic }
                                }
                            }
                        `, delegateRoot);
                        entryAnim.start();
                    }
                    border.width: mouseArea.containsMouse ? 3 : 1
                    border.color: mouseArea.containsMouse ? "#a6e3a1" : "#585b70"
                    states: [
                        State {
                            name: "visible"
                            when: delegateRoot.opacity > 0 && !mouseArea.containsMouse && wallpaperView.hoveredIndex === -1
                            PropertyChanges {
                                target: delegateRoot
                                opacity: 1.0
                                scale: 1.0
                                border.color: "#585b70"
                                border.width: 1
                            }
                        },
                        State {
                            name: "hovered"
                            when: mouseArea.containsMouse
                            PropertyChanges {
                                target: delegateRoot
                                opacity: 1.0
                                scale: 1.1
                                border.color: "#a6e3a1"
                                border.width: 3
                            }
                        },
                        State {
                            name: "dimmed"
                            when: wallpaperView.hoveredIndex !== -1 && !mouseArea.containsMouse
                            PropertyChanges {
                                target: delegateRoot
                                opacity: 0.6
                                scale: 0.85
                                border.color: "#585b70"
                                border.width: 1
                            }
                        }
                    ]
                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: wallpaperView.hoveredIndex = index
                        onExited: wallpaperView.hoveredIndex = -1
                        onClicked: {
                            const transitions = ["simple", "fade", "left", "right", "top", "bottom", "wipe", "wave", "grow", "center", "any", "outer", "pixel", "wheel"];
                            let rand = Math.floor(Math.random() * transitions.length);
                            let selectedTransition = transitions[rand];
                            swwwSetter.command = ["swww", "img", model.path, "--transition-type", selectedTransition, "--transition-fps", "144", "--transition-duration", "1.2"];
                            swwwSetter.running = true;
                        }
                    }
                }
            }
        }
        Process {
            running: true
            command: ["sh", "-c", "find ~/Pictures/Wallpapers -type f \\( -iname \"*.jpg\" -o -iname \"*.png\" -o -iname \"*.webp\" -o -iname \"*.jpeg\" \\) | shuf -n 25"]
            stdout: StdioCollector {
                onStreamFinished: {
                    let paths = this.text.trim().split("\n");
                    wallpaperModel.clear();
                    for (let p of paths) {
                        if (p.trim() !== "") {
                            wallpaperModel.append({
                                "path": p.trim()
                            });
                        }
                    }
                }
            }
        }
        Process {
            id: swwwSetter
        }
    }
}
