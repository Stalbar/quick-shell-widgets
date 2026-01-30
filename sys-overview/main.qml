import QtQuick.Layouts
import Quickshell
import QtQuick
import Quickshell.Wayland
import Quickshell.Io
import Qt5Compat.GraphicalEffects

PanelWindow {
    id: root
    readonly property string globalFont: "JetBrainsMono Nerd Font"
    WlrLayershell.keyboardFocus: WlrLayershell.OnDemand
    focusable: true
    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.exclusionMode: WlrLayershell.None
    WlrLayershell.namespace: "system_dashboard"

    anchors {
        top: true
        right: true
    }

    margins {
        top: 200
        right: 480
    }

    Behavior on margins.top {
        NumberAnimation {
            duration: 500
            easing.type: Easing.OutBack
        }
    }
    Component.onCompleted: {
        root.margins.top = 200;
    }

    color: "transparent"

    implicitHeight: 610
    implicitWidth: 970

    component SystemInfoItem: RowLayout {
        property string label: ""
        property string value: ""
        property string textColor: ""
        property real percentage: 0
        spacing: 15
        Text {
            text: label + ": "
            color: textColor
            font.pixelSize: 18
            font.bold: true
            font.family: globalFont
            Layout.preferredWidth: 200
            horizontalAlignment: Text.AlignLeft
        }
        Text {
            text: value !== "" ? value : "Loading..."
            color: textColor
            font.pixelSize: 18
            font.family: globalFont
            Layout.fillWidth: true
        }
        Rectangle {
            width: 150
            height: 10
            color: "#313244"
            radius: 5
            visible: label.match(/RAM|Swap|CPU|Root|Home|Battery/i)
            Rectangle {
                width: (parent.width * percentage) / 100
                height: parent.height
                color: textColor
                radius: 5
                Behavior on width {
                    NumberAnimation {
                        duration: 500
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }

    Rectangle {
        id: mainContainer
        anchors.fill: parent
        color: "#ccb4befe"
        radius: 10
        opacity: 0
        scale: 0.7
        border.width: 1
        border.color: "#22ffffff"
        Behavior on opacity {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutCubic
            }
        }
        Behavior on scale {
            NumberAnimation {
                duration: 450
                easing.type: Easing.OutCubic
                easing.amplitude: 1.5
            }
        }
        Component.onCompleted: {
            mainContainer.opacity = 1;
            mainContainer.scale = 1.0;
        }
        Item {
            focus: true
            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape) {
                    mainContainer.opacity = 0;
                    mainContainer.scale = 0.9;
                    const quitTimer = Qt.createQmlObject('import QtQuick; Timer { interval: 300; onTriggered: Qt.quit() }', root);
                    quitTimer.start();
                }
            }
        }
        DropShadow {
            anchors.fill: mainContainer
            horizontalOffset: 0
            verticalOffset: 8
            radius: 16.0
            samples: 24
            color: "#80000000"
            source: mainContainer
            z: -1
        }
        Rectangle {
            anchors.fill: parent
            anchors.margins: 5
            color: "#e011111b"
            radius: 5
            ColumnLayout {
                anchors.fill: parent
                spacing: 5
                anchors.margins: 10
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    RowLayout {
                        spacing: 10
                        Rectangle {
                            width: 60
                            height: 60
                            radius: 30
                            color: "#313244"
                            Text {
                                anchors.centerIn: parent
                                text: "󰣇"
                                color: "#f5e0dc"
                                font.pixelSize: 40
                                font.bold: true
                            }
                        }
                        Text {
                            id: usernameText
                            color: "#cdd6f4"
                            font.pixelSize: 24
                            font.bold: true
                            verticalAlignment: Text.AlignVCenter
                            Process {
                                command: ["whoami"]
                                running: true
                                stdout: StdioCollector {
                                    onStreamFinished: usernameText.text = "Hi, " + this.text.trim()
                                }
                            }
                        }
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    Text {
                        id: timeText
                        color: "#94e2d5"
                        font.pixelSize: 24
                        font.bold: true
                        verticalAlignment: Text.AlignVCenter
                        Timer {
                            interval: 1000
                            running: true
                            repeat: true
                            onTriggered: timeText.text = Qt.formatTime(new Date(), "HH:mm:ss")
                            Component.onCompleted: timeText.text = Qt.formatTime(new Date(), "HH:mm:ss")
                        }
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    height: 2
                    color: "#313244"
                }
                ColumnLayout {
                    spacing: 8
                    Layout.fillWidth: true
                    SystemInfoItem {
                        id: osItem
                        label: " 󰣇 OS"
                        textColor: "#89b4fa"
                        Process {
                            command: ["sh", "-c", "grep 'PRETTY_NAME' /etc/os-release | cut -d'\"' -f2"]
                            running: true
                            stdout: StdioCollector {
                                onStreamFinished: osItem.value = this.text.trim()
                            }
                        }
                    }
                    SystemInfoItem {
                        id: kernelItem
                        label: "  Kernel"
                        textColor: "#89b4fa"
                        Process {
                            command: ["sh", "-c", "uname -r"]
                            running: true
                            stdout: StdioCollector {
                                onStreamFinished: kernelItem.value = this.text.trim()
                            }
                        }
                    }
                    SystemInfoItem {
                        id: deItem
                        label: "  DE"
                        textColor: "#89b4fa"
                        Process {
                            command: ["sh", "-c", "echo $XDG_CURRENT_DESKTOP"]
                            running: true
                            stdout: StdioCollector {
                                onStreamFinished: deItem.value = this.text.trim()
                            }
                        }
                    }
                    SystemInfoItem {
                        id: protocolItem
                        label: "  Protocol"
                        textColor: "#89b4fa"
                        Process {
                            command: ["sh", "-c", "echo $XDG_SESSION_TYPE"]
                            running: true
                            stdout: StdioCollector {
                                onStreamFinished: protocolItem.value = this.text.trim()
                            }
                        }
                    }
                    SystemInfoItem {
                        id: ramItem
                        label: "  RAM"
                        textColor: "#94e2d5"
                        Process {
                            id: ramProc
                            running: true
                            command: ["sh", "-c", "free -m | awk '/Mem:/ { printf(\"%.1fGiB / %.1fGiB (%d%%)|%d\", $3/1024, $2/1024, $3/$2*100, $3/$2*100) }'"]
                            stdout: StdioCollector {
                                onStreamFinished: {
                                    let rawData = this.text.trim();
                                    if (rawData.includes("|")) {
                                        let parts = rawData.split("|");
                                        ramItem.value = parts[0];
                                        let numValue = parseFloat(parts[1].replace(/[^0-9.]/g, ''));
                                        ramItem.percentage = isNaN(numValue) ? 0 : numValue;
                                    }
                                }
                            }
                        }
                        Timer {
                            interval: 5000
                            running: true
                            repeat: true
                            onTriggered: ramProc.running = true
                        }
                    }
                    SystemInfoItem {
                        id: swapItem
                        label: " 󰾴 Swap"
                        textColor: "#94e2d5"
                        Process {
                            id: swapProcess
                            command: ["sh", "-c", "free -m | awk '/Swap:/ { if($2>0) printf(\"%.1fGiB / %.1fGiB (%d%%)|%d\", $3/1024, $2/1024, $3/$2*100, $3/$2*100); else print \"None|0\" }'"]
                            running: true
                            stdout: StdioCollector {
                                onStreamFinished: {
                                    let rawData = this.text.trim();
                                    if (rawData.includes("|")) {
                                        let parts = rawData.split("|");
                                        swapItem.value = parts[0];
                                        let numValue = parseFloat(parts[1].replace(/[^0-9.]/g, ''));
                                        swapItem.percentage = isNaN(numValue) ? 0 : numValue;
                                    }
                                }
                            }
                        }
                        Timer {
                            interval: 5000
                            running: true
                            repeat: true
                            onTriggered: swapProcess.running = true
                        }
                    }
                    SystemInfoItem {
                        id: uptimeItem
                        label: "  Uptime"
                        textColor: "#94e2d5"
                        Process {
                            id: uptimeProc
                            command: ["sh", "-c", "awk '{s=int($1); h=int(s/3600); m=int((s%3600)/60); s=s%60; printf \"%02dh %02dm %02ds\", h, m, s}' /proc/uptime"]
                            running: true
                            stdout: StdioCollector {
                                onStreamFinished: uptimeItem.value = this.text.trim()
                            }
                        }
                        Timer {
                            interval: 1000
                            onTriggered: uptimeProc.running = true
                            running: true
                            repeat: true
                        }
                    }
                    SystemInfoItem {
                        id: hostItem
                        label: "  Host"
                        textColor: "#fab387"
                        Process {
                            command: ["sh", "-c", "cat /sys/devices/virtual/dmi/id/product_name"]
                            running: true
                            stdout: StdioCollector {
                                onStreamFinished: hostItem.value = this.text.trim()
                            }
                        }
                    }
                    SystemInfoItem {
                        id: hostnameItem
                        label: "  Hostname"
                        textColor: "#fab387"
                        Process {
                            command: ["sh", "-c", "cat /proc/sys/kernel/hostname"]
                            running: true
                            stdout: StdioCollector {
                                onStreamFinished: hostnameItem.value = this.text.trim()
                            }
                        }
                    }
                    SystemInfoItem {
                        id: packagesItem
                        label: "  Packages"
                        textColor: "#fab387"
                        Process {
                            command: ["sh", "-c", "pacman -Q | wc -l"]
                            running: true
                            stdout: StdioCollector {
                                onStreamFinished: packagesItem.value = this.text.trim()
                            }
                        }
                    }
                    SystemInfoItem {
                        id: cpuItem
                        label: " 󰻠 CPU"
                        textColor: "#a6e3a1"
                        Process {
                            id: cpuProc
                            command: ["sh", "-c", "NAME=$(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | sed 's/  */ /g'); USAGE_RAW=$(top -bn2 -d 0.5 | grep 'Cpu(s)' | tail -n1 | awk '{print 100 - $8}'); echo \"$NAME ($USAGE_RAW%)|$USAGE_RAW\""]
                            running: true
                            stdout: StdioCollector {
                                onStreamFinished: {
                                    let rawData = this.text.trim();
                                    if (rawData.includes("|")) {
                                        let parts = rawData.split("|");
                                        cpuItem.value = parts[0];
                                        let numValue = parseFloat(parts[1].replace(/[^0-9.]/g, ''));
                                        cpuItem.percentage = isNaN(numValue) ? 0 : numValue;
                                    }
                                }
                            }
                        }
                        Timer {
                            interval: 5000
                            running: true
                            repeat: true
                            onTriggered: cpuProc.running = true
                        }
                    }
                    SystemInfoItem {
                        id: iGpuItem
                        label: " 󰢮 GPU"
                        textColor: "#a6e3a1"
                        Process {
                            command: ["sh", "-c", "lspci | grep -i 'VGA.*Intel' | sed -n 's/.*\\[\\(.*\\)\\].*/\\1/p'"]
                            running: true
                            stdout: StdioCollector {
                                onStreamFinished: iGpuItem.value = this.text.trim()
                            }
                        }
                    }
                    SystemInfoItem {
                        id: dGpuItem
                        label: " 󰢮 GPU"
                        textColor: "#a6e3a1"
                        Process {
                            command: ["sh", "-c", "lspci | grep -i 'NVIDIA' | sed -n 's/.*\\[\\(.*\\)\\].*/\\1/p'"]
                            running: true
                            stdout: StdioCollector {
                                onStreamFinished: dGpuItem.value = this.text.trim()
                            }
                        }
                    }
                    SystemInfoItem {
                        id: rootPartitionItem
                        label: "  Root"
                        textColor: "#f5c2e7"
                        Process {
                            command: ["sh", "-c", "df -hT / | awk 'NR>1 { p=$6; gsub(/%/,\"\",p); printf(\"%s / %s (%s) [%s]|%d\", $4, $3, $6, $2, p) }'"]
                            running: true
                            stdout: StdioCollector {
                                onStreamFinished: {
                                    let rawData = this.text.trim();
                                    if (rawData.includes("|")) {
                                        let parts = rawData.split("|");
                                        rootPartitionItem.value = parts[0];
                                        let numValue = parseFloat(parts[1].replace(/[^0-9.]/g, ''));
                                        rootPartitionItem.percentage = isNaN(numValue) ? 0 : numValue;
                                    }
                                }
                            }
                        }
                    }
                    SystemInfoItem {
                        id: homePartitionItem
                        label: "  Home"
                        textColor: "#f5c2e7"
                        Process {
                            command: ["sh", "-c", "df -hT /home | awk 'NR>1 { p=$6; gsub(/%/,\"\",p); printf(\"%s / %s (%s) [%s]|%d\", $4, $3, $6, $2, p) }'"]
                            running: true
                            stdout: StdioCollector {
                                onStreamFinished: {
                                    let rawData = this.text.trim();
                                    if (rawData.includes("|")) {
                                        let parts = rawData.split("|");
                                        homePartitionItem.value = parts[0];
                                        let numValue = parseFloat(parts[1].replace(/[^0-9.]/g, ''));
                                        homePartitionItem.percentage = isNaN(numValue) ? 0 : numValue;
                                    }
                                }
                            }
                        }
                    }
                    SystemInfoItem {
                        id: batteryItem
                        label: " 󰂀 Battery"
                        textColor: "#f5c2e7"
                        Process {
                            command: ["sh", "-c", "CAP=$(cat /sys/class/power_supply/BAT0/capacity); STAT=$(cat /sys/class/power_supply/BAT0/status); echo \"$CAP% [$STAT]|$CAP\""]
                            running: true
                            stdout: StdioCollector {
                                onStreamFinished: {
                                    let rawData = this.text.trim();
                                    if (rawData.includes("|")) {
                                        let parts = rawData.split("|");
                                        batteryItem.value = parts[0];
                                        let numValue = parseFloat(parts[1].replace(/[^0-9.]/g, ''));
                                        batteryItem.percentage = isNaN(numValue) ? 0 : numValue;
                                    }
                                }
                            }
                        }
                    }
                    Item {
                        Layout.fillHeight: true
                    }
                }
            }
        }
    }
}
