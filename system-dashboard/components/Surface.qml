import QtQuick
import Qt5Compat.GraphicalEffects

Item {
  id: root
  property var theme
  property int radius: 18
  property bool interactive: false
  property color baseColor: Qt.rgba(0.066, 0.066, 0.106, 0.82) 
  property color borderColor: Qt.rgba(1, 1, 1, 0.06)

  signal clicked()

  implicitHeight: 200
  implicitWidth: 320

  property real hover: 0
  property real press: 0

  Rectangle {
    id: bg
    anchors.fill: parent
    radius: root.radius
    color: Qt.rgba(
      root.baseColor.r + 0.02 * root.hover,
      root.baseColor.g + 0.02 * root.hover,
      root.baseColor.b + 0.02 * root.hover,
      root.baseColor.a + 0.02 * root.hover
    )
    border.width: 1
    border.color: Qt.rgba(1, 1, 1, 0.06 + 0.08 * root.hover)
  }

  DropShadow {
    anchors.fill: bg
    source: bg
    radius: 18 * 10 * root.hover
    samples: 26
    verticalOffset: 8 + 6 * root.hover
    color: Qt.rgba(0, 0, 0, 0.20 * 0.18 * root.hover)
    visible: root.interactive
    z: -1
  }

  MouseArea {
    anchors.fill: parent
    enabled: root.interactive
    hoverEnabled: true
    onEntered: root.hover = 1
    onExited: root.hover = 0
    onPressed: root.press = 1
    onReleased: root.press = 0
    onClicked: root.clicked()
  }

  scale: 1.0 - 0.01 * root.press + 0.01 * root.hover
  Behavior on scale { NumberAnimation { duration: theme.durMed; easing.type: theme.easeOut } }
  Behavior on hover { NumberAnimation { duration: theme.durMed; easing.type: theme.easeOut } }
  Behavior on press { NumberAnimation { duration: theme.durFast; easing.type: theme.easeOut } }
}
