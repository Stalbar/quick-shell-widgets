import QtQuick
import QtQuick.Layouts

RowLayout {
  id: root
  property string title: ""
  property string icon: ""
  property var theme
  property string fontFamily: ""

  spacing: 10
  Layout.fillWidth: true
  Layout.preferredHeight: 34

  Text {
    text: root.icon
    color: theme.subtext1
    font.pixelSize: 18
    font.family: root.fontFamily
    Layout.alignment: Qt.AlignVCenter
  }

  Text {
    text: root.title
    color: theme.text
    font.pixelSize: 18
    font.bold: true
    font.family: root.fontFamily
    Layout.alignment: Qt.AlignVCenter
  }

  Item { Layout.fillWidth: true }

  Rectangle {
    width: 8
    height: 8
    radius: 4
    color: theme.surface2
    opacity: 0.6
    Layout.alignment: Qt.AlignVCenter
  }
}
