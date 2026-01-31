import QtQuick

Item {
  id: root
  property real value: 0
  property color accent: "#89b4fa"
  property color track: "#313244"
  property int heightPx: 10
  property int widthPx: 150

  width: widthPx
  height: heightPx

  Rectangle {
    anchors.fill: parent
    radius: height / 2
    color: root.track
    opacity: 0.9
    Rectangle {
      width: Math.max(height, (parent.width * Math.max(0, Math.min(100, root.value))) / 100)
      height: parent.height
      radius: height / 2
      color: root.accent

      Behavior on width {
        NumberAnimation { duration: 450; easing.type: Easing.OutCubic }
      }
    }
  }
}
