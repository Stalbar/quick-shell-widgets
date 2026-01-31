import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland

import "theme" as T
import "components" as C

PanelWindow {
    id: root
    readonly property string globalFont: "JetBrainsMono Nerd Font"
    readonly property var theme: T.Theme {}

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
        top: 105
        right: 440
    }

    color: "transparent"
    implicitWidth: 980
    implicitHeight: 700

    property real shown: 0
    Behavior on shown {
        NumberAnimation {
            duration: 420
            easing.type: Easing.OutCubic
        }
    }
    Component.onCompleted: shown = 1

    C.AcryllicCard {
        id: glass
        anchors.fill: parent
        theme: root.theme
        radius: theme.radiusOuter
        tint: theme.acrylicTint
        overlayOpacity: 1.0
        elevated: true

        opacity: root.shown
        scale: 0.92 + 0.08 * root.shown
        Behavior on opacity {
            NumberAnimation {
                duration: 220
                easing.type: Easing.OutCubic
            }
        }
        Behavior on scale {
            NumberAnimation {
                duration: 420
                easing.type: Easing.OutBack
            }
        }

        Item {
            anchors.fill: parent
            focus: true
            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape) {
                    root.shown = 0;
                    const quitTimer = Qt.createQmlObject('import QtQuick; Timer { interval: 260; onTriggered: Qt.quit() }', root);
                    quitTimer.start();
                }
            }
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: theme.gap + 2
            anchors.margins: 18

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 64
                spacing: 12

                Rectangle {
                    width: 48
                    height: 48
                    radius: 14
                    color: theme.surface0
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.08)

                    Text {
                        anchors.centerIn: parent
                        text: "󰣇"
                        color: theme.rosewater
                        font.pixelSize: 28
                        font.bold: true
                    }
                }

                ColumnLayout {
                    spacing: 2
                    Layout.preferredWidth: 520

                    Text {
                        id: greet
                        text: "Hi"
                        color: theme.text
                        font.pixelSize: 20
                        font.bold: true
                        font.family: globalFont
                        elide: Text.ElideRight
                    }

                    Text {
                        id: subtitle
                        text: "Arch • Hyprland • System Overview"
                        color: theme.subtext0
                        font.pixelSize: 13
                        font.family: globalFont
                        opacity: 0.9
                        elide: Text.ElideRight
                    }

                    C.CommandProcess {
                        command: ["whoami"]
                        onTextChanged: greet.text = "Hi, " + text.trim()
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                Rectangle {
                    radius: 999
                    color: theme.surface0
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.08)
                    Layout.preferredHeight: 36
                    Layout.preferredWidth: 140

                    Text {
                        id: timeText
                        anchors.centerIn: parent
                        color: theme.teal
                        font.pixelSize: 16
                        font.bold: true
                        font.family: globalFont
                    }

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
                height: 1
                color: Qt.rgba(1, 1, 1, 0.08)
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 12

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: 200
                    radius: 18
                    color: Qt.rgba(1, 1, 1, 0.03)
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.06)

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 10

                        C.SectionHeader {
                            title: "System"
                            icon: "󰒋"
                            theme: root.theme
                            fontFamily: globalFont
                        }

                        C.StatRow {
                            id: osItem
                            label: "OS"
                            value: ""
                            accent: theme.blue
                            theme: root.theme
                            fontFamily: globalFont

                            C.CommandProcess {
                                command: ["sh", "-c", "grep 'PRETTY_NAME' /etc/os-release | cut -d'\"' -f2"]
                                onTextChanged: osItem.value = text.trim()
                            }
                        }

                        C.StatRow {
                            id: uptimeItem
                            label: "Uptime"
                            value: ""
                            percentage: -1
                            accent: theme.blue
                            theme: root.theme
                            fontFamily: globalFont

                            C.CommandProcess {
                                id: uptimeProc
                                command: ["sh", "-c", "awk '{s=int($1); h=int(s/3600); m=int((s%3600)/60); s=s%60; printf \"%02dh %02dm %02ds\", h, m, s}' /proc/uptime"]
                                onTextChanged: uptimeItem.value = text.trim()
                            }

                            Timer {
                                interval: 1000
                                running: true
                                repeat: true
                                onTriggered: uptimeProc.restart()
                            }
                        }

                        C.StatRow {
                            id: kernelItem
                            label: "Kernel"
                            value: ""
                            accent: theme.lavender
                            theme: root.theme
                            fontFamily: globalFont

                            C.CommandProcess {
                                command: ["uname", "-r"]
                                onTextChanged: kernelItem.value = text.trim()
                            }
                        }

                        C.StatRow {
                            id: hostItem
                            label: "Host"
                            value: ""
                            accent: theme.peach
                            theme: root.theme
                            fontFamily: globalFont
                            isElide: true

                            C.CommandProcess {
                                command: ["sh", "-c", "cat /etc/hostname 2>/dev/null | head -n1 | tr -d ' \n\t' || hostname 2>/dev/null || uname -n"]
                                onTextChanged: hostItem.value = text.trim() !== "" ? text.trim() : "—"
                            }
                        }

                        C.StatRow {
                            id: pkgsItem
                            label: "Packages"
                            value: ""
                            accent: theme.green
                            theme: root.theme
                            fontFamily: globalFont

                            C.CommandProcess {
                                command: ["sh", "-c", "pacman -Qq 2>/dev/null | wc -l | awk '{print $1\" (pacman)\"}'"]
                                onTextChanged: pkgsItem.value = text.trim()
                            }
                        }

                        C.StatRow {
                            id: shellItem
                            label: "Shell"
                            value: ""
                            accent: theme.sky
                            theme: root.theme
                            fontFamily: globalFont

                            C.CommandProcess {
                                command: ["sh", "-c", "echo \"$SHELL\" | sed 's:.*/::'"]
                                onTextChanged: shellItem.value = text.trim()
                            }
                        }

                        C.StatRow {
                            id: wmItem
                            label: "WM"
                            value: "Hyprland"
                            accent: theme.mauve
                            theme: root.theme
                            fontFamily: globalFont
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: Qt.rgba(1, 1, 1, 0.08)
                        }

                        C.SectionHeader {
                            title: "Hyprland"
                            icon: ""
                            theme: root.theme
                            fontFamily: globalFont
                        }

                        C.WorkspacePills {
                            id: wsPills
                            theme: root.theme
                            activeId: -1
                            fontFamily: globalFont
                            ids: []
                        }

                        C.StatRow {
                            id: hyprWsItem
                            label: "Workspace"
                            value: ""
                            percentage: -1
                            accent: theme.mauve
                            theme: root.theme
                            fontFamily: globalFont

                            C.CommandProcess {
                                id: hyprWsProc
                                command: ["sh", "-c", "hyprctl activeworkspace -j 2>/dev/null || echo '{}'"]
                                autoStart: true
                                onTextChanged: {
                                    const s = text;
                                    const mId = s.match(/"id"\s*:\s*([0-9]+)/);
                                    const mName = s.match(/"name"\s*:\s*([^"]+)"/);
                                    const id = mId ? mId[1] : "?";
                                    const name = mName ? mName[1] : id;
                                    hyprWsItem.value = `#${id} (${name})`;
                                    wsPills.activeId = parseInt(id);
                                }
                            }

                            Timer {
                                interval: 1200
                                running: true
                                repeat: true
                                onTriggered: hyprWsProc.restart()
                            }
                        }

                        C.StatRow {
                            id: hyprWinItem
                            label: "Active"
                            value: ""
                            percentage: -1
                            accent: theme.lavender
                            theme: root.theme
                            fontFamily: globalFont
                            isElide: true

                            C.CommandProcess {
                                id: hyprWinProc
                                command: ["sh", "-c", "hyprctl activewindow -j 2>/dev/null || echo '{}'"]
                                autoStart: true
                                onTextChanged: {
                                    const s = text;
                                    const mClass = s.match(/"class"\s*:\s*"([^"]*)"/) || s.match(/"initialClass"\s*:\s*"([^\"]*)"/);
                                    const mTitle = s.match(/"title"\s*:\s*"([^"]*)"/);
                                    const cls = (mClass && mClass[1]) ? mClass[1] : "-";
                                    const title = (mTitle && mTitle[1]) ? mTitle[1] : "-";
                                    hyprWinItem.value = `${cls} * ${title}`;
                                }
                            }

                            Timer {
                                interval: 1200
                                running: true
                                repeat: true
                                onTriggered: hyprWinProc.restart()
                            }
                        }

                        C.StatRow {
                            id: hyprListItem
                            label: "Workspaces"
                            value: ""
                            percentage: -1
                            accent: theme.sky
                            theme: root.theme
                            fontFamily: globalFont
                            property string lastValue: ""

                            C.CommandProcess {
                                id: hyprListProc
                                command: ["sh", "-c", "hyprctl workspaces -j 2>/dev/null || echo '[]'"]
                                autoStart: true
                                onTextChanged: {
                                    const s = text;

                                    let ids = [];
                                    let out = [];
                                    const re = /\{[^}]*\"id\"\s*:\s*([0-9]+)[^}]*\}/g;
                                    let match;
                                    while ((match = re.exec(s)) !== null) {
                                        const chunkStart = match.index;
                                        const chunkEnd = s.indexOf("}", chunkStart);
                                        const chunk = chunkEnd > chunkStart ? s.slice(chunkStart, chunkEnd + 1) : "";

                                        const mId = chunk.match(/\"id\"\s*:\s*([0-9]+)/);
                                        const mWin = chunk.match(/\"windows\"\s*:\s*([0-9]+)/);

                                        if (mId) {
                                            const id = mId[1];
                                            ids.push(parseInt(id));
                                            const win = mWin ? mWin[1] : "0";
                                            out.push(`${id}(${win})`);
                                        }
                                    }

                                    ids.sort((a, b) => a - b);
                                    wsPills.ids = ids;
                                    const joined = out.length ? out.join("  ") : "—";
                                    hyprListItem.value = joined;
                                }
                            }

                            Timer {
                                interval: 2000
                                running: true
                                repeat: true
                                onTriggered: hyprListProc.restart()
                            }
                        }

                        Item {
                            Layout.fillHeight: true
                        }
                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 540
                    radius: 18
                    color: Qt.rgba(1, 1, 1, 0.03)
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.06)

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 10

                        C.SectionHeader {
                            title: "Performance"
                            icon: "󰄩"
                            theme: root.theme
                            fontFamily: globalFont
                        }

                        C.StatRow {
                            id: ramItem
                            label: "RAM"
                            value: ""
                            percentage: 0
                            accent: theme.teal
                            theme: root.theme
                            fontFamily: globalFont

                            C.CommandProcess {
                                id: ramProc
                                command: ["sh", "-c", "free -m | awk '/Mem:/ { total=$2; avail=$7; used=total-avail; pct=(used/total)*100; " + "printf(\"Used %.1fGiB • Avail %.1fGiB (%.0f%%)|%.0f\", used/1024, avail/1024, pct, pct) }'"]
                                onTextChanged: {
                                    let raw = text.trim();
                                    if (raw.includes("|")) {
                                        let parts = raw.split("|");
                                        ramItem.value = parts[0];
                                        let p = parseFloat(parts[1].replace(/[^0-9.]/g, ""));
                                        ramItem.percentage = isNaN(p) ? 0 : p;
                                    }
                                }
                            }

                            Timer {
                                interval: 5000
                                running: true
                                repeat: true
                                onTriggered: ramProc.restart()
                            }
                        }

                        C.StatRow {
                            id: cpuItem
                            label: "CPU"
                            value: ""
                            percentage: 0
                            accent: theme.green
                            theme: root.theme
                            fontFamily: globalFont

                            C.CommandProcess {
                                id: cpuProc
                                command: ["sh", "-c", "NAME=$(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | sed 's/  */ /g'); " + "USAGE=$(top -bn2 -d 0.4 | grep 'Cpu(s)' | tail -n1 | awk '{print 100 - $8}'); " + "printf \"%s (%.0f%%)|%.0f\" \"$NAME\" \"$USAGE\" \"$USAGE\""]
                                onTextChanged: {
                                    let raw = text.trim();
                                    if (raw.includes("|")) {
                                        let parts = raw.split("|");
                                        cpuItem.value = parts[0];
                                        let p = parseFloat(parts[1].replace(/[^0-9.]/g, ""));
                                        cpuItem.percentage = isNaN(p) ? 0 : p;
                                    }
                                }
                            }

                            Timer {
                                interval: 5000
                                running: true
                                repeat: true
                                onTriggered: cpuProc.restart()
                            }
                        }

                        C.StatRow {
                            id: swapItem
                            label: "Swap"
                            value: ""
                            percentage: 0
                            accent: theme.teal
                            theme: root.theme
                            fontFamily: globalFont

                            C.CommandProcess {
                                id: swapProc
                                command: ["sh", "-c", "free -m | awk '/Swap:/ { total=$2; used=$3; " + "if (total>0) { pct=(used/total)*100; printf(\"%.1fGiB / %.1fGiB (%.0f%%)|%.0f\", used/1024, total/1024, pct, pct); } " + "else { print \"None|0\"; } }'"]
                                onTextChanged: {
                                    let raw = text.trim();
                                    if (raw.includes("|")) {
                                        let parts = raw.split("|");
                                        swapItem.value = parts[0];
                                        let p = parseFloat(parts[1].replace(/[^0-9.]/g, ""));
                                        swapItem.percentage = isNaN(p) ? 0 : p;
                                    }
                                }
                            }

                            Timer {
                                interval: 5000
                                running: true
                                repeat: true
                                onTriggered: swapProc.restart()
                            }
                        }

                        C.StatRow {
                            id: igpuItem
                            label: "iGPU"
                            value: ""
                            accent: theme.sky
                            theme: root.theme
                            fontFamily: globalFont
                            isElide: true

                            C.CommandProcess {
                                command: ["sh", "-c", "lspci 2>/dev/null | grep -iE 'VGA|3D|Display' | grep -i intel | head -n1 | " + "sed -E 's/.*: //; s/\\(R\\)//g; s/Intel Corporation //g; s/  +/ /g; s/.*(UHD Graphics [0-9]+).*/\\1/;'"]
                                onTextChanged: igpuItem.value = text.trim() !== "" ? text.trim() : "—"
                            }
                        }

                        C.StatRow {
                            id: dgpuItem
                            label: "dGPU"
                            value: ""
                            accent: theme.mauve
                            theme: root.theme
                            fontFamily: globalFont
                            isElide: true

                            C.CommandProcess {
                                command: ["sh", "-c", "lspci 2>/dev/null | grep -i nvidia | head -n1 | awk '" + "{" + "  if ($0 ~ /GTX[[:space:]]+1650/) { print \"GeForce GTX 1650 Mobile\"; exit }" + "  if (match($0, /\\[GeForce ([^\\]]+)\\]/, a)) n=a[1];" + "  else if (match($0, /GeForce (.*)$/, a)) n=a[1];" + "  gsub(/Max-Q|with Max-Q|\\(.*\\)/, \"\", n);" + "  sub(/\\/.*/, \"\", n);" + "  gsub(/[[:space:]]+/, \" \", n);" + "  gsub(/^[ ]+|[ ]+$/, \"\", n);" + "  if (n == \"\") { print \"—\"; exit }" + "  if (n ~ /Mobile/) print \"GeForce \" n; else print \"GeForce \" n \" Mobile\";" + "}'"]
                                onTextChanged: dgpuItem.value = text.trim() !== "" ? text.trim() : "—"
                            }
                        }

                        C.StatRow {
                            id: displayItem
                            label: "Displays"
                            value: ""
                            accent: theme.sky
                            theme: root.theme
                            fontFamily: globalFont
                            isElide: true

                            C.CommandProcess {
                                id: monProc
                                command: ["sh", "-c", "hyprctl monitors -j 2>/dev/null || echo '[]'"]
                                onTextChanged: {
                                    const s = text;
                                    const names = [];
                                    const re = /\"name\"\s*:\s*\"([^\"]+)\"/g;
                                    let m;
                                    while ((m = re.exec(s)) !== null)
                                        names.push(m[1]);
                                    displayItem.value = names.length ? names.join(", ") : "—";
                                }
                            }

                            Timer {
                                interval: 5000
                                running: true
                                repeat: true
                                onTriggered: monProc.restart()
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: Qt.rgba(1, 1, 1, 0.08)
                        }

                        C.SectionHeader {
                            title: "Storage"
                            icon: "󰋊"
                            theme: root.theme
                            fontFamily: globalFont
                        }

                        C.StatRow {
                            id: rootDiskItem
                            label: "Root"
                            value: ""
                            percentage: 0
                            accent: theme.pink
                            theme: root.theme
                            fontFamily: globalFont

                            C.CommandProcess {
                                id: rootDiskProc
                                command: ["sh", "-c", "df -h / | awk 'NR==2 { p=$5; gsub(/%/,\"\",p); printf(\"%s free / %s (%s)|%d\", $4, $2, $5, p) }'"]
                                onTextChanged: {
                                    let raw = text.trim();
                                    if (raw.includes("|")) {
                                        let parts = raw.split("|");
                                        rootDiskItem.value = parts[0];
                                        let p = parseFloat(parts[1].replace(/[^0-9.]/g, ""));
                                        rootDiskItem.percentage = isNaN(p) ? 0 : p;
                                    }
                                }
                            }

                            Timer {
                                interval: 15000
                                running: true
                                repeat: true
                                onTriggered: rootDiskProc.restart()
                            }
                        }

                        C.StatRow {
                            id: homeDiskItem
                            label: "Home"
                            value: ""
                            percentage: 0
                            accent: theme.pink
                            theme: root.theme
                            fontFamily: globalFont

                            C.CommandProcess {
                                id: homeDiskProc
                                command: ["sh", "-c", "df -h /home 2>/dev/null | awk 'NR==2 { p=$5; gsub(/%/,\"\",p); printf(\"%s free / %s (%s)|%d\", $4, $2, $5, p) } END { if (NR<2) print \"N/A|0\" }'"]
                                onTextChanged: {
                                    let raw = text.trim();
                                    if (raw.includes("|")) {
                                        let parts = raw.split("|");
                                        homeDiskItem.value = parts[0];
                                        let p = parseFloat(parts[1].replace(/[^0-9.]/g, ""));
                                        homeDiskItem.percentage = isNaN(p) ? 0 : p;
                                    }
                                }
                            }

                            Timer {
                                interval: 15000
                                running: true
                                repeat: true
                                onTriggered: homeDiskProc.restart()
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: Qt.rgba(1, 1, 1, 0.08)
                        }

                        C.SectionHeader {
                            title: "Power"
                            icon: "󰂁"
                            theme: root.theme
                            fontFamily: globalFont
                        }

                        C.StatRow {
                            id: batteryItem
                            label: "Battery"
                            value: ""
                            percentage: 0
                            accent: theme.yellow
                            theme: root.theme
                            fontFamily: globalFont

                            C.CommandProcess {
                                id: batteryProc
                                command: ["sh", "-c", "if [ -e /sys/class/power_supply/BAT0/capacity ]; then " + "cap=$(cat /sys/class/power_supply/BAT0/capacity); " + "stat=$(cat /sys/class/power_supply/BAT0/status); " + "printf \"%s%% [%s]|%s\" \"$cap\" \"$stat\" \"$cap\"; " + "else echo \"N/A|0\"; fi"]
                                onTextChanged: {
                                    let raw = text.trim();
                                    if (raw.includes("|")) {
                                        let parts = raw.split("|");
                                        batteryItem.value = parts[0];
                                        let p = parseFloat(parts[1].replace(/[^0-9.]/g, ""));
                                        batteryItem.percentage = isNaN(p) ? 0 : p;
                                    }
                                }
                            }

                            Timer {
                                interval: 15000
                                running: true
                                repeat: true
                                onTriggered: batteryProc.restart()
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
}
