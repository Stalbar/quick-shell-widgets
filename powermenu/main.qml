import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick.Effects

PanelWindow {
    id: powerRoot
    anchors {
        left: true
        right: true
        top: true
        bottom: true
    }
    color: "#1111111b"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "powermenu"
    WlrLayershell.keyboardFocus: WlrLayershell.Exclusive
    focusable: true

    signal closeTrigger

    function closeMenu() {
        mainContainer.opacity = 0;
        powerRoot.closeTrigger();
        quitTimer.start();
    }

    Timer {
        id: quitTimer
        interval: 800
        onTriggered: Qt.quit()
    }

    MouseArea {
        anchors.fill: parent
        onClicked: powerRoot.closeMenu()
    }

    Process {
        id: executor
    }

    Item {
        id: mainContainer
        anchors.fill: parent
        opacity: 0
        Behavior on opacity {
            NumberAnimation {
                duration: 400
            }
        }
        Component.onCompleted: opacity = 1.0

        Text {
            anchors.centerIn: parent
            text: wheelContainer.hoveredName
            font.pixelSize: 32
            font.weight: Font.Bold
            color: "#cdd6f4"
            opacity: text === "" ? 0 : 1
            Behavior on opacity {
                NumberAnimation {
                    duration: 250
                }
            }
        }

        Item {
            id: wheelContainer
            anchors.centerIn: parent
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 100
            property string hoveredName: ""
            property int hoveredIndex: -1
            focus: true

            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape)
                    powerRoot.closeMenu();
            }

            Repeater {
                model: [
                    {
                        i: "⏻",
                        c: "systemctl poweroff",
                        n: "Shutdown"
                    },
                    {
                        i: "",
                        c: "systemctl reboot",
                        n: "Reboot"
                    },
                    {
                        i: "󰿅",
                        c: "hyprctl dispatch exit",
                        n: "Exit"
                    },
                    {
                        i: "",
                        c: "systemctl suspend",
                        n: "Suspend"
                    },
                    {
                        i: "",
                        c: "hyprlock",
                        n: "Lock"
                    },
                    {
                        i: "",
                        c: "systemctl hibernate",
                        n: "Hibernate"
                    }
                ]
                delegate: Rectangle {
                    id: delegateRoot
                    property real animatedRadius: 0
                    readonly property real targetRadius: 180
                    readonly property real angle: (index * 60 + 180) * (Math.PI / 180)

                    x: animatedRadius * Math.cos(angle) - width / 2
                    y: animatedRadius * Math.sin(angle) - height / 2
                    width: 75
                    height: 75
                    radius: width / 2

                    color: mArea.containsMouse ? "#74c7ec" : "#1e1e2e"
                    border.color: mArea.containsMouse ? "#89b4fa" : "#313244"
                    border.width: 2
                    opacity: animatedRadius / targetRadius

                    states: [
                        State {
                            name: "dimmed"
                            when: wheelContainer.hoveredIndex !== -1 && wheelContainer.hoveredIndex !== index
                            PropertyChanges {
                                target: delegateRoot
                                scale: 0.8
                                opacity: 0.6
                            }
                        },
                        State {
                            name: "hovered"
                            when: mArea.containsMouse
                            PropertyChanges {
                                target: delegateRoot
                                scale: 1.25
                                opacity: 1.0
                            }
                        },
                        State {
                            name: "normal"
                            when: wheelContainer.hoveredIndex === -1 || wheelContainer.hoveredIndex === index && !mArea.containsMouse
                            PropertyChanges {
                                target: delegateRoot
                                scale: 1.0
                                opacity: 1.0
                            }
                        }
                    ]
                    transitions: Transition {
                        ScaleAnimator {
                            duration: 250
                            easing.type: Easing.OutQuint
                        }
                        OpacityAnimator {
                            duration: 200
                        }
                    }

                    Behavior on animatedRadius {
                        NumberAnimation {
                            duration: 500
                            easing.type: delegateRoot.animatedRadius > 0 ? Easing.OutQuint : Easing.InBack
                        }
                    }
                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    Timer {
                        running: true
                        interval: index * 50
                        onTriggered: delegateRoot.animatedRadius = delegateRoot.targetRadius
                    }

                    Connections {
                        target: powerRoot
                        function onCloseTrigger() {
                            const reverseDelay = (5 - index) * 50;
                            exitTimer.interval = reverseDelay;
                            exitTimer.start();
                        }
                    }

                    Timer {
                        id: exitTimer
                        onTriggered: delegateRoot.animatedRadius = 0
                    }

                    Text {
                        text: modelData.i
                        anchors.centerIn: parent
                        font.pixelSize: 30
                        color: mArea.containsMouse ? "#11111b" : "#cdd6f4"
                    }

                    MouseArea {
                        id: mArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: {
                            wheelContainer.hoveredName = modelData.n;
                            wheelContainer.hoveredIndex = index;
                        }
                        onExited: {
                            wheelContainer.hoveredName = "";
                            wheelContainer.hoveredIndex = -1;
                        }
                        onClicked: {
                            executor.command = modelData.c.split(" ");
                            executor.running = true;
                            powerRoot.closeMenu();
                        }
                    }
                }
            }
        }
    }
}
