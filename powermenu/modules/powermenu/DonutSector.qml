import QtQuick
import QtQuick.Shapes
import Qt5Compat.GraphicalEffects

import "../../theme" as Theme

Item {
    id: root

    Theme.Tokens { id: tokens }
    Theme.CatppuccinMocha { id: mocha }

    property real innerRadius: 160
    property real outerRadius: 280
    property real startAngle: 0
    property real sweepAngle: 60

    property color accent: "#cba6f7"
    property string label: ""
    property string iconText: ""
    property string fontFamily: "JetBrainsMono Nerd Font"

    property bool hovered: false
    property real progress: 1

    property real neonIntensity: 1.0

    property int staggerIndex: 0
    property int staggerCount: 1
    property real staggerStep: 0.035

    property real hoverT: hovered ? 1 : 0
    Behavior on hoverT {
        NumberAnimation { duration: 180; easing.type: Easing.OutQuad }
    }

    readonly property real staggerDelay: Math.min(0.30, staggerIndex * staggerStep)
    readonly property real appearRaw: (progress - staggerDelay) / Math.max(0.0001, (1.0 - staggerDelay))
    readonly property real appearT: Math.max(0.0, Math.min(1.0, appearRaw))
    readonly property real appearE: appearT * appearT * (3.0 - 2.0 * appearT) // smoothstep

    property real rimInsetDeg: 2.2
    property real neonGlowWidth: 7
    property real neonCoreWidth: 2.2
    property real neonGlowRadius: 18
    property real neonGlowSpread: 0.14
    property real neonGlowAlpha: 0.20
    property real neonCoreAlpha: 0.62
    property real neonBloomOpacity: 0.22

    readonly property color neonGlowColor: accent
    readonly property color neonCoreColor: Qt.lighter(accent, 1.22)

    readonly property real cx: width / 2
    readonly property real cy: height / 2
    readonly property real midAngle: startAngle + sweepAngle / 2

    function pt(r, deg) {
        const rad = deg * Math.PI / 180.0
        return Qt.point(cx + r * Math.cos(rad), cy + r * Math.sin(rad))
    }

    opacity: progress

    scale: 0.99 + 0.02 * hoverT
    Behavior on scale {
        NumberAnimation { duration: 180; easing.type: Easing.OutQuad }
    }

    Shape {
        id: seg
        anchors.fill: parent
        layer.enabled: true
        layer.samples: 8

        ShapePath {
            startX: root.pt(root.outerRadius, root.startAngle).x
            startY: root.pt(root.outerRadius, root.startAngle).y

            strokeWidth: 1
            strokeColor: Qt.rgba(1, 1, 1, 0.05)

            fillColor: Qt.rgba(
                0.08 + 0.14 * root.hoverT * root.accent.r,
                0.08 + 0.14 * root.hoverT * root.accent.g,
                0.12 + 0.14 * root.hoverT * root.accent.b,
                0.26 + 0.22 * root.hoverT
            )

            PathArc {
                x: root.pt(root.outerRadius, root.startAngle + root.sweepAngle).x
                y: root.pt(root.outerRadius, root.startAngle + root.sweepAngle).y
                radiusX: root.outerRadius
                radiusY: root.outerRadius
                useLargeArc: root.sweepAngle > 180
                direction: PathArc.Clockwise
            }
            PathLine {
                x: root.pt(root.innerRadius, root.startAngle + root.sweepAngle).x
                y: root.pt(root.innerRadius, root.startAngle + root.sweepAngle).y
            }
            PathArc {
                x: root.pt(root.innerRadius, root.startAngle).x
                y: root.pt(root.innerRadius, root.startAngle).y
                radiusX: root.innerRadius
                radiusY: root.innerRadius
                useLargeArc: root.sweepAngle > 180
                direction: PathArc.Counterclockwise
            }
            PathLine {
                x: root.pt(root.outerRadius, root.startAngle).x
                y: root.pt(root.outerRadius, root.startAngle).y
            }
        }
    }

    Item {
        id: neonLayer
        anchors.fill: parent
        visible: root.hoverT > 0.01
        opacity: root.progress

        readonly property real a0: root.startAngle + root.rimInsetDeg
        readonly property real a1: root.startAngle + root.sweepAngle - root.rimInsetDeg
        readonly property real arcSweep: Math.max(0, a1 - a0)
        readonly property bool largeArc: arcSweep > 180

        readonly property var o0: root.pt(root.outerRadius, a0)
        readonly property var o1: root.pt(root.outerRadius, a1)
        readonly property var i1: root.pt(root.innerRadius, a1)
        readonly property var i0: root.pt(root.innerRadius, a0)

        Shape {
            id: neonHalo
            anchors.fill: parent
            layer.enabled: true
            layer.samples: 8

            ShapePath {
                startX: neonLayer.o0.x
                startY: neonLayer.o0.y

                strokeWidth: root.neonGlowWidth
                strokeColor: Qt.rgba(
                    root.neonGlowColor.r, root.neonGlowColor.g, root.neonGlowColor.b,
                    root.neonGlowAlpha * root.hoverT * root.neonIntensity
                )
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap
                joinStyle: ShapePath.RoundJoin

                PathArc {
                    x: neonLayer.o1.x
                    y: neonLayer.o1.y
                    radiusX: root.outerRadius
                    radiusY: root.outerRadius
                    useLargeArc: neonLayer.largeArc
                    direction: PathArc.Clockwise
                }
                PathLine { x: neonLayer.i1.x; y: neonLayer.i1.y }
                PathArc {
                    x: neonLayer.i0.x
                    y: neonLayer.i0.y
                    radiusX: root.innerRadius
                    radiusY: root.innerRadius
                    useLargeArc: neonLayer.largeArc
                    direction: PathArc.Counterclockwise
                }
                PathLine { x: neonLayer.o0.x; y: neonLayer.o0.y }
            }
        }

        Shape {
            id: neonCore
            anchors.fill: parent
            layer.enabled: true
            layer.samples: 8

            ShapePath {
                startX: neonLayer.o0.x
                startY: neonLayer.o0.y

                strokeWidth: root.neonCoreWidth
                strokeColor: Qt.rgba(
                    root.neonCoreColor.r, root.neonCoreColor.g, root.neonCoreColor.b,
                    root.neonCoreAlpha * root.hoverT * root.neonIntensity
                )
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap
                joinStyle: ShapePath.RoundJoin

                PathArc {
                    x: neonLayer.o1.x
                    y: neonLayer.o1.y
                    radiusX: root.outerRadius
                    radiusY: root.outerRadius
                    useLargeArc: neonLayer.largeArc
                    direction: PathArc.Clockwise
                }
                PathLine { x: neonLayer.i1.x; y: neonLayer.i1.y }
                PathArc {
                    x: neonLayer.i0.x
                    y: neonLayer.i0.y
                    radiusX: root.innerRadius
                    radiusY: root.innerRadius
                    useLargeArc: neonLayer.largeArc
                    direction: PathArc.Counterclockwise
                }
                PathLine { x: neonLayer.o0.x; y: neonLayer.o0.y }
            }
        }

        Glow {
            anchors.fill: neonCore
            source: neonCore
            radius: root.neonGlowRadius
            spread: root.neonGlowSpread
            color: root.neonGlowColor
            opacity: root.neonBloomOpacity * root.hoverT * root.neonIntensity
        }
    }

    Item {
        id: content

        readonly property real rText: root.innerRadius + (root.outerRadius - root.innerRadius) * 0.52
        readonly property var p: root.pt(rText, root.midAngle)

        width: 210
        height: 130

        readonly property real baseX: p.x - width / 2
        readonly property real baseY: p.y - height / 2

        x: baseX
        y: baseY + (1.0 - root.appearE) * 10

        opacity: root.appearE

        scale: (0.98 + 0.02 * root.appearE) * (1.0 + 0.04 * root.hoverT)

        Column {
            anchors.centerIn: parent
            spacing: 10

            Text {
                text: root.iconText
                color: root.hoverT > 0
                    ? Qt.rgba(root.neonCoreColor.r, root.neonCoreColor.g, root.neonCoreColor.b, 0.98)
                    : Qt.rgba(mocha.text.r, mocha.text.g, mocha.text.b, 0.92)
                font.family: root.fontFamily
                font.pixelSize: 32
                font.weight: Font.DemiBold
                anchors.horizontalCenter: parent.horizontalCenter
                renderType: Text.NativeRendering
            }

            Text {
                text: root.label
                color: root.hoverT > 0
                    ? Qt.rgba(root.neonCoreColor.r, root.neonCoreColor.g, root.neonCoreColor.b, 0.92)
                    : Qt.rgba(mocha.subtext.r, mocha.subtext.g, mocha.subtext.b, 0.92)
                font.family: root.fontFamily
                font.pixelSize: 18
                font.weight: Font.Medium
                font.letterSpacing: 0.6
                anchors.horizontalCenter: parent.horizontalCenter
                renderType: Text.NativeRendering
            }
        }
    }
}

