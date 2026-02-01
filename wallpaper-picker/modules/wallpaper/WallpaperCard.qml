import QtQuick
import Qt5Compat.GraphicalEffects
import "../../theme" as Theme
import "../../ui" as UI

Item {
    id: card
    width: 342
    height: 140

    property string path: ""
    property bool dimmed: false
    property bool isHovered: false
    property bool isPressed: false
    property bool selected: false
    signal clicked(string path)
    signal hovered(bool inside)

    opacity: dimmed ? 0.60 : 1.0
    z: isHovered ? 10 : 0

    Behavior on z {
        NumberAnimation {
            duration: Theme.Tokens.durFast
        }
    }
    Behavior on opacity {
        NumberAnimation {
            duration: Theme.Tokens.durMed
        }
    }

    Item {
        id: content
        anchors.centerIn: parent
        width: parent.width
        height: parent.height

        Rectangle {
            id: shadowPlate
            anchors.fill: parent
            radius: Theme.Tokens.radiusMd
            color: "transparent"
            visible: true
        }

        UI.GlowShadow {
            anchors.fill: shadowPlate
            sourceItem: shadowPlate
            glowColor: card.selected ? Theme.CatppuccinMocha.cyan : Theme.CatppuccinMocha.mauve
            glowStrength: (card.selected || card.isHovered) ? 0.22 : 0.06
            yOffset: card.isHovered ? 18 : 10
            radius: card.isHovered ? 38 : 26
            spread: 0.12

            Behavior on glowStrength {
                NumberAnimation {
                    duration: Theme.Tokens.durMed
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on yOffset {
                NumberAnimation {
                    duration: Theme.Tokens.durMed
                    easing.type: Easing.OutCubic
                }
            }
        }

        Item {
            id: visual
            anchors.fill: parent
            transformOrigin: Item.Center
            scale: card.isPressed ? 1.04 : (card.isHovered ? 1.10 : (card.dimmed ? 0.88 : 1.0))

            Behavior on scale {
                NumberAnimation {
                    duration: Theme.Tokens.durMed
                    easing.type: Easing.OutCubic
                }
            }

            Rectangle {
                id: plate
                anchors.fill: parent
                radius: Theme.Tokens.radiusMd
                color: Theme.CatppuccinMocha.base
                antialiasing: true

                border.width: (card.selected || card.isHovered) ? 3 : 1
                border.color: card.selected ? Theme.CatppuccinMocha.cyan : (card.isHovered ? Theme.Tokens.focus : Theme.CatppuccinMocha.surface)
                Behavior on border.color {
                    ColorAnimation {
                        duration: Theme.Tokens.durFast
                    }
                }
            }
            Rectangle {
                id: imgClip
                anchors.fill: plate
                anchors.margins: 4
                radius: plate.radius - 4
                color: "transparent"
                antialiasing: true

                Image {
                    id: img
                    anchors.fill: parent
                    source: card.path.length > 0 ? ("file://" + card.path) : ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    cache: true
                    smooth: true

                    layer.enabled: true
                    layer.smooth: true
                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            width: img.width
                            height: img.height
                            radius: imgClip.radius
                            antialiasing: true
                            color: "white"
                        }
                    }
                }

                UI.Ripple {
                    id: ripple
                    anchors.fill: parent
                    rippleColor: Qt.rgba(1, 1, 1, 0.14)
                }
            }
        }
    }

    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        z: 999

        onEntered: {
            card.isHovered = true;
            card.hovered(true);
        }
        onExited: {
            card.isHovered = false;
            card.hovered(false);
        }
        onClicked: {
            ripple.burst(mouse.x, mouse.y);
            card.clicked(card.path);
        }
        onPressed: card.isPressed = true
        onReleased: card.isPressed = false
        onCanceled: card.isPressed = false
    }
}
