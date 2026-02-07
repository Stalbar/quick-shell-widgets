import QtQuick
import Quickshell.Io

QtObject {
    id: action

    required property string actionId
    required property string label
    required property string command

    property string iconText: ""
    property color accent: "#cba6f7"
    property int key: 0 

    property real neonIntensity: 1.0

    readonly property Process proc: Process {
        command: ["sh", "-c", action.command]
    }

    function exec() {
        proc.startDetached()
    }
}

