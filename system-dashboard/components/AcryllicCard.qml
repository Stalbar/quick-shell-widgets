import QtQuick
import Qt5Compat.GraphicalEffects

Item {
  id: root
  property alias contentItem: content
  property int radius: 20
  property color tint: theme.acrylicTint
  property color borderColor: theme.border
  property real blurRadius: 28
  property real overlayOpacity: 1.0
  property bool elevated: true
  property bool glow: true
  property color glowColor: theme.glowSoft

  property var theme

  property Item blurSourceItem: null

  implicitWidth: 900
  implicitHeight: 560

  DropShadow {
    anchors.fill: card
    horizontalOffset: 0
    verticalOffset: 16
    radius: 30
    samples: 36
    color: theme.shadowSoft
    source: card
    visible: root.elevated
    z: -4
  }
  DropShadow {
    anchors.fill: card
    horizontalOffset: 0
    verticalOffset: 8
    radius: 20
    samples: 28
    color: theme.shadowStrong
    source: card
    visible: root.elevated
    z: -3
  }

  ShaderEffectSource {
    id: bgSource
    anchors.fill: card
    sourceItem: root.blurSourceItem
    live: true
    visible: root.blurSourceItem !== null
    hideSource: false
    recursive: true
  }

  FastBlur { 
    anchors.fill: bgSource
    source: bgSource
    radius: root.blurRadius
    visible: bgSource.visible
    z: -1
  }

  Rectangle {
    id: card
    anchors.fill: parent
    radius: root.radius
    color: theme.acrylicTint
    border.width: 1
    border.color: theme.border 

    Rectangle {
      anchors.fill: parent
      radius: root.radius
      gradient: Gradient {
        GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.08) }
        GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.02) }
      }
      opacity: 0.9
    }

    Rectangle {
      anchors.fill: parent
      radius: root.radius
      color: theme.acrylicOverlay
      opacity: root.overlayOpacity
    }

    Canvas {
      id: noise
      anchors.fill: parent
      opacity: 0.06
      onPaint: {
        const ctx = getContext("2d")
        ctx.clearRect(0, 0, width, height)
        const n = 2200
        for (let i = 0; i < n; i++) {
          const x = Math.random() * width;
          const y = Math.random() * height;
          const a = Math.random() * 0.18;
          ctx.fillStyle = "rgba(255, 255, 255, " + a + ")";
          ctx.fillRect(x, y, 1, 1);
        }
      }
      Timer { interval: 250; running: true; repeat: true; onTriggered: noise.requestPaint()}
    }

    Rectangle {
      anchors.fill: parent
      radius: root.radius
      color: "transparent"
      border.width: root.glow ? 1 : 0
      border.color: root.glow ? Qt.rgba(root.glowColor.r, root.glowColor.g, root.glowColor.b, 0.55) : "transparent"
      visible: root.glow
    }

    Item {
      id: content
      anchors.fill: parent
      anchors.margins: theme.padding
    }
  }
}
