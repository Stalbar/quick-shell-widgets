import QtQuick
import "../theme" as Theme
import "." as UI

Item {
    id: root
    property int radius: Theme.Tokens.radiusLg
    property color tint: Theme.Tokens.bgTint
    property color outline: Theme.Tokens.outline
    property real outlineOpacity: 0.65
    property bool glow: true

    property real elevation: 1.0

    default property alias content: contentItem.data

    Rectangle {
        id: shape
        anchors.fill: parent
        radius: root.radius
        color: root.tint
        border.width: 1
        border.color: Qt.rgba(root.outline.r, root.outline.g, root.outline.b, root.outlineOpacity)
    }

    Rectangle {
        anchors.fill: shape
        radius: shape.radius
        color: "transparent"
        border.width: 0

        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: Qt.rgba(1, 1, 1, 0.10)
            }
            GradientStop {
                position: 0.5
                color: Qt.rgba(1, 1, 1, 0.03)
            }
            GradientStop {
                position: 1.0
                color: Qt.rgba(1, 1, 1, 0.00)
            }
        }
        opacity: 0.7
    }

    UI.GlowShadow {
        visible: root.glow
        sourceItem: shape
        glowColor: Theme.CatppuccinMocha.cyan
        glowStrength: 0.22 * root.elevation
        yOffset: 10 * root.elevation
        radius: 28
        spread: 0.16
    }

    UI.Noise {
      anchors.fill: shape
      opacity: 0.045
    }

    Item {
        id: contentItem
        anchors.fill: parent
    }
}
