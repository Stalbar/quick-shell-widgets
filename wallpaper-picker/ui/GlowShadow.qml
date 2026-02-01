import QtQuick
import Qt5Compat.GraphicalEffects

Item {
  id: root
  anchors.fill: parent
  visible: sourceItem !== null

  property Item sourceItem: null

  property color glowColor: "#74c7ec"
  property real glowStrength: 0.35
  property real radius: 28
  property real yOffset: 10
  property real spread: 0.18

  DropShadow {
    anchors.fill: parent
    radius: root.radius
    samples: 32
    verticalOffset: root.yOffset
    spread: root.spread
    color: Qt.rgba(root.glowColor.r, root.glowColor.g, root.glowColor.b, root.glowStrength)
    source: root.sourceItem
  }
}
