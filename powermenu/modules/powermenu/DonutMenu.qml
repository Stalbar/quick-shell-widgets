import QtQuick
import QtQuick.Shapes
import Qt5Compat.GraphicalEffects

import "../../theme" as Theme
import "../../ui" as UI

Item {
    id: root

    Theme.Tokens {
        id: tokens
    }
    Theme.CatppuccinMocha {
        id: mocha
    }

    property list<PowerAction> actions
    property real outerRadius: 280
    property real innerRadius: 160
    property real gapDegrees: 6
    property real progress: 1

    property string fontFamily: "JetBrainsMono Nerd Font"
    property string centerIconText: ""

    // NEW: stagger (as a fraction of 0..1 progress) per sector index
    property real contentStaggerStep: 0.035

    // background ring padding
    property real ringPad: 22
    readonly property real ringOuter: outerRadius + ringPad
    readonly property real ringInner: innerRadius - ringPad

    signal triggered(PowerAction action)

    property int hoveredIndex: -1

    readonly property int n: actions ? actions.length : 0
    readonly property real step: n > 0 ? 360 / n : 360
    readonly property real baseAngle: -90 - step / 2

    readonly property real cx: width / 2
    readonly property real cy: height / 2

    function pt(r, deg) {
        const rad = deg * Math.PI / 180.0;
        return Qt.point(cx + r * Math.cos(rad), cy + r * Math.sin(rad));
    }

    function easeOutCubic(t) {
        return 1.0 - Math.pow(1.0 - t, 3.0);
    }
    readonly property real e: easeOutCubic(Math.max(0, Math.min(1, progress)))

    transformOrigin: Item.Center
    scale: 0.90 + 0.10 * e
    rotation: -8 * (1 - e)
    opacity: progress

    function indexFromPoint(p) {
        if (n <= 0)
            return -1;
        const dx = p.x - cx;
        const dy = p.y - cy;
        const r = Math.sqrt(dx * dx + dy * dy);
        if (r < innerRadius || r > outerRadius)
            return -1;

        let deg = Math.atan2(dy, dx) * 180 / Math.PI;
        if (deg < 0)
            deg += 360;

        let rel = (deg - baseAngle) % 360;
        if (rel < 0)
            rel += 360;

        const idx = Math.floor(rel / step);
        const local = rel - idx * step;
        if (local < gapDegrees / 2 || local > step - gapDegrees / 2)
            return -1;
        return idx;
    }

    UI.Ripple {
        id: ripple
    }

    HoverHandler {
        onPointChanged: root.hoveredIndex = root.indexFromPoint(point.position)
        onActiveChanged: if (!active)
            root.hoveredIndex = -1
    }

    TapHandler {
        onTapped: {
            const idx = root.indexFromPoint(point.position);
            if (idx >= 0) {
                const a = root.actions[idx];
                ripple.burst(point.position.x, point.position.y, a.accent);
                root.triggered(a);
            }
        }
    }

    Shape {
        id: ring
        anchors.fill: parent
        layer.enabled: true
        layer.samples: 8

        readonly property var o0: root.pt(root.ringOuter, 0)
        readonly property var o180: root.pt(root.ringOuter, 180)
        readonly property var i0: root.pt(root.ringInner, 0)
        readonly property var i180: root.pt(root.ringInner, 180)

        ShapePath {
            startX: ring.o0.x
            startY: ring.o0.y

            strokeWidth: 1
            strokeColor: Qt.rgba(1, 1, 1, 0.03)
            fillColor: Qt.rgba(mocha.mauve.r, mocha.mauve.g, mocha.mauve.b, 0.18)

            PathArc {
                x: ring.o180.x
                y: ring.o180.y
                radiusX: root.ringOuter
                radiusY: root.ringOuter
                direction: PathArc.Clockwise
            }
            PathArc {
                x: ring.o0.x
                y: ring.o0.y
                radiusX: root.ringOuter
                radiusY: root.ringOuter
                direction: PathArc.Clockwise
            }
            PathLine {
                x: ring.i0.x
                y: ring.i0.y
            }
            PathArc {
                x: ring.i180.x
                y: ring.i180.y
                radiusX: root.ringInner
                radiusY: root.ringInner
                direction: PathArc.Counterclockwise
            }
            PathArc {
                x: ring.i0.x
                y: ring.i0.y
                radiusX: root.ringInner
                radiusY: root.ringInner
                direction: PathArc.Counterclockwise
            }
            PathLine {
                x: ring.o0.x
                y: ring.o0.y
            }
        }
    }

    Glow {
        anchors.fill: ring
        source: ring
        radius: 18
        spread: 0.14
        color: mocha.mauve
        opacity: 0.10 * e
    }

    Repeater {
        model: root.actions
        delegate: DonutSector {
            anchors.fill: parent

            innerRadius: root.innerRadius
            outerRadius: root.outerRadius
            startAngle: root.baseAngle + index * root.step + root.gapDegrees / 2
            sweepAngle: root.step - root.gapDegrees

            accent: modelData.accent
            label: modelData.label
            iconText: modelData.iconText

            fontFamily: root.fontFamily
            hovered: root.hoveredIndex === index
            progress: root.progress

            neonIntensity: (typeof modelData.neonIntensity === "number") ? modelData.neonIntensity : 1.0

            // NEW: stagger inputs
            staggerIndex: index
            staggerCount: root.n
            staggerStep: root.contentStaggerStep
        }
    }

    Item {
        anchors.centerIn: parent
        width: innerRadius * 1.06
        height: width
        opacity: root.progress
        scale: 0.94 + 0.06 * e

        UI.AcrylicPanel {
            id: puck
            anchors.fill: parent
            radius: width / 2
            opacityBase: 0.58
            showHighlight: false
        }

        UI.GlowShadow {
            sourceItem: puck
            glowColor: mocha.blue
            glowOpacity: 0.12 * e
            glowRadius: 14
            shadowRadius: 24
            shadowOpacity: 0.35
            shadowYOffset: 9
        }

        Text {
            anchors.centerIn: parent
            text: root.centerIconText
            color: mocha.text
            font.family: root.fontFamily
            font.pixelSize: Math.round(innerRadius * 0.56)
            renderType: Text.NativeRendering
        }
    }
}
