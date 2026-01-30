import Quickshell
import Quickshell.Wayland
import QtQuick

PanelWindow {
  id: launcherRoot
  anchors {
    top: true
    bottom: true
    left: true
    right: true
  }
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
  color: "#8011111b"
  visible: true
  Rectangle {
    id: launcherBox
    width: 450
    height: 350
    color: "#1e1e2e"
    border.color: "#cba6f7"
    border.width: 2
    radius: 12
    anchors.centerIn: parent
    focus: true
    Component.onCompleted: forceActiveFocus()
    Keys.onEscapePressed: {
      Qt.quit();
    } 
    Column {
      anchors.fill: parent
      anchors.margins: 20
      spacing: 15
      Text {
        text: "App Launcher"
        color: "#cdd6f4"
        font.pixelSize: 22
        font.bold: true
        anchors.horizontalCenter: parent.horizontalCenter
      }
      Rectangle {
        width: parent.width - 40
        height: 40
        color: "#313244"
        radius: 6
        anchors.horizontalCenter: parent.horizontalCenter

        Text {
          anchors.centerIn: parent
          text: "Search Apps..."
          color: "#a6adc8"
        }
      }
    }
  }
}
