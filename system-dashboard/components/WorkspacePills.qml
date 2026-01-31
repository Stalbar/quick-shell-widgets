import QtQuick
import QtQuick.Layouts

RowLayout {
  id: root
  property var theme
  property string fontFamily: ""
  property int activeId: -1
  property var ids: []
  property int maxShown: 10

  spacing: 8
  Layout.fillWidth: true

  Repeater {
    model: Math.min(root.ids.length, root.maxShown)
    delegate: Rectangle {
      required property int index
      property int wsId: root.ids[index]
      readonly property bool isActive: wsId === root.activeId

      radius: 999
      height: 22
      width: 32

      color: isActive ? Qt.rgba(1, 1, 1, 0.10) : Qt.rgba(1, 1, 1, 0.04)
      border.width: 1
      border.color: isActive ?  Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(1, 1, 1, 0.08)

      Behavior on width { NumberAnimation { duration: 220; easing.type: Easing.OutCubic}}
      Behavior on color { ColorAnimation { duration: 220 } }
      Behavior on border.color { ColorAnimation { duration: 220 }}

      Text {
        anchors.centerIn: parent
        text: wsId
        color: isActive ? theme.mauve : theme.subtext0
        font.pixelSize: 13
        font.bold: isActive
        font.family: root.fontFamily
      }
    }
  }

  Item { Layout.fillWidth: true }
}
