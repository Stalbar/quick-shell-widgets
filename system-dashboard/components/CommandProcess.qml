import QtQuick
import Quickshell.Io

Item {
  id: root

  property var command: []
  property string text: ""
  property bool autoStart: true

  function restart() {
    proc.running = false;
    restartTimer.start();
  }

  Timer {
    id: restartTimer
    interval: 0
    repeat: false
    onTriggered: proc.running = true
  }

  Process {
    id: proc
    command: root.command
    running: root.autoStart
    stdout: StdioCollector {
      onStreamFinished: root.text = this.text
    }
  }

  Component.onCompleted: {
    if (autoStart)
      restart()
  }
}
