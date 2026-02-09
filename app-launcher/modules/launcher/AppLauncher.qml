import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell
import Quickshell.Widgets

import "." as Launcher

Item {
    id: root
    required property var controller
    signal requestClose

    readonly property string rawQuery: String(controller.query || "")
    readonly property string trimmedQuery: rawQuery.trim()
    readonly property bool commandMode: trimmedQuery.startsWith(">") || trimmedQuery.startsWith(":")
    readonly property string commandPrefix: commandMode ? trimmedQuery.charAt(0) : ""
    readonly property string commandTerm: commandMode ? trimmedQuery.slice(1).trim() : ""

    readonly property string uiFamily: (Launcher.Typography && Launcher.Typography.family !== undefined) ? String(Launcher.Typography.family) : Qt.application.font.family

    readonly property int searchSize: (Launcher.Typography && Launcher.Typography.search !== undefined) ? Number(Launcher.Typography.search) : 16

    readonly property int footerSize: (Launcher.Typography && Launcher.Typography.footer !== undefined) ? Number(Launcher.Typography.footer) : 11

    readonly property var chipModel: (Launcher.Tags && Launcher.Tags.chips !== undefined) ? Launcher.Tags.chips : []

    function focusSearch() {
        search.forceActiveFocus();
        search.selectAll();
    }

    function rowCount() {
        const n = results.values ? results.values.length : 0;
        return Math.ceil(n / 2);
    }

    function ensureSelectedVisible() {
        const row = Math.floor(controller.selectedIndex / 2);
        list.positionViewAtIndex(Math.max(0, row), ListView.Contain);
    }

    function allApps() {
        const all0 = Array.from(DesktopEntries.applications.values);
        const out = [];
        for (const e of all0) {
            if (!e)
                continue;
            if (e.noDisplay)
                continue;

            const id = String(e.id || "").toLowerCase();
            const name = String(e.name || "").toLowerCase();
            if (id === "btop" || id === "btop.desktop" || name === "btop")
                continue;

            out.push(e);
        }
        return out;
    }

    function buildPinned(pool) {
        if (commandMode)
            return [];
        if (trimmedQuery.length > 0)
            return [];

        const pins = (Launcher.LauncherState && Launcher.LauncherState.pins) ? Launcher.LauncherState.pins : [];
        const byId = new Map(pool.map(e => [String(e.id || ""), e]));
        const out = [];
        for (const id of pins) {
            const it = byId.get(String(id));
            if (it)
                out.push(it);
            if (out.length >= 10)
                break;
        }
        return out;
    }

    ScriptModel {
        id: results

        values: {
            if (root.commandMode) {
                return Launcher.Commands.build(root.commandTerm, root.commandPrefix);
            }

            const all = root.allApps();

            const tag = String(controller.activeTag || "All");
            let pool = all;

            if (Launcher.Tags && Launcher.Tags.matches) {
                if (tag === "Pinned")
                    pool = all.filter(e => Launcher.Tags.matches(e, "Pinned"));
                else if (tag !== "All" && tag !== "Frequent")
                    pool = all.filter(e => Launcher.Tags.matches(e, tag));
            }

            const usage = (Launcher.LauncherState && Launcher.LauncherState.usage) ? Launcher.LauncherState.usage : {};
            const q = root.trimmedQuery.toLowerCase();

            if (!q) {
                const pinned = buildPinned(pool);
                const pinnedSet = new Set(pinned.map(e => String(e.id || "")));

                const rest = pool.filter(e => !pinnedSet.has(String(e.id || "")));

                rest.sort((a, b) => {
                    const ua = usage[String(a.id || "")] || 0;
                    const ub = usage[String(b.id || "")] || 0;
                    if (ub !== ua)
                        return ub - ua;
                    return String(a.name || a.id || "").localeCompare(String(b.name || b.id || ""));
                });

                const out = (tag === "Frequent") ? rest : pinned.concat(rest);
                return out.slice(0, controller.maxResults);
            }

            const tokens = q.split(/\s+/).filter(Boolean);
            const scored = [];

            for (const e of pool) {
                const name = String(e.name || "").toLowerCase();
                const generic = String(e.genericName || "").toLowerCase();
                const id = String(e.id || "").toLowerCase();
                const keywords = (e.keywords || []).join(" ").toLowerCase();
                const hay = `${name} ${generic} ${keywords} ${id}`;

                let ok = true;
                let score = 0;

                for (const t of tokens) {
                    const pos = hay.indexOf(t);
                    if (pos < 0) {
                        ok = false;
                        break;
                    }
                    score += (1000 - pos);
                    if (name.startsWith(t))
                        score += 320;
                }
                if (!ok)
                    continue;

                if (Launcher.LauncherState && Launcher.LauncherState.isPinned && Launcher.LauncherState.isPinned(String(e.id || "")))
                    score += 240;

                const u = usage[String(e.id || "")] || 0;
                score += Math.min(220, Math.log(1 + u) * 80);

                scored.push({
                    e,
                    score
                });
            }

            scored.sort((a, b) => b.score - a.score);

            const out2 = [];
            const lim = Math.min(scored.length, controller.maxResults);
            for (let i = 0; i < lim; i++)
                out2.push(scored[i].e);
            return out2;
        }

        onValuesChanged: {
            const n = values ? values.length : 0;
            if (controller.selectedIndex >= n)
                controller.selectedIndex = Math.max(0, n - 1);
            if (n === 0)
                controller.selectedIndex = 0;
            Qt.callLater(ensureSelectedVisible);
        }
    }

    readonly property var pinnedEntries: buildPinned(allApps())

    ColumnLayout {
        anchors.fill: parent
        spacing: 6

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            radius: 20
            color: Qt.rgba(1, 1, 1, 0.05)
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.10)

            RowLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                IconImage {
                    Layout.preferredWidth: 18
                    Layout.preferredHeight: 18
                    source: Quickshell.iconPath("system-search", "edit-find")
                    opacity: 0.9
                }

                TextField {
                    id: search
                    Layout.fillWidth: true

                    text: controller.query
                    placeholderText: "Search apps…   (> shell, : terminal)"
                    background: null
                    color: Launcher.Palette.text
                    placeholderTextColor: Qt.rgba(Launcher.Palette.subtext0.r, Launcher.Palette.subtext0.g, Launcher.Palette.subtext0.b, 0.85)

                    font.family: root.uiFamily
                    font.pixelSize: root.searchSize

                    selectByMouse: true

                    onTextEdited: {
                        controller.query = text;
                        controller.selectedIndex = 0;
                        Qt.callLater(ensureSelectedVisible);
                    }

                    Keys.onPressed: event => {
                        const cols = controller.columns;
                        const count = results.values ? results.values.length : 0;

                        function clamp(i) {
                            if (count <= 0)
                                return 0;
                            return Math.max(0, Math.min(i, count - 1));
                        }

                        if (event.key === Qt.Key_Escape) {
                            event.accepted = true;
                            root.requestClose();
                            return;
                        }

                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            event.accepted = true;
                            const it = results.values[controller.selectedIndex];
                            if (it)
                                controller.launch(it);
                            return;
                        }

                        if (!root.commandMode && (event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_P) {
                            event.accepted = true;
                            const it2 = results.values[controller.selectedIndex];
                            if (it2 && it2.id && Launcher.LauncherState)
                                Launcher.LauncherState.togglePin(String(it2.id));
                            return;
                        }

                        if (event.key === Qt.Key_Down) {
                            event.accepted = true;
                            controller.selectedIndex = clamp(controller.selectedIndex + cols);
                            Qt.callLater(ensureSelectedVisible);
                            return;
                        }
                        if (event.key === Qt.Key_Up) {
                            event.accepted = true;
                            controller.selectedIndex = clamp(controller.selectedIndex - cols);
                            Qt.callLater(ensureSelectedVisible);
                            return;
                        }
                        if (event.key === Qt.Key_Left) {
                            event.accepted = true;
                            controller.selectedIndex = clamp(controller.selectedIndex - 1);
                            Qt.callLater(ensureSelectedVisible);
                            return;
                        }
                        if (event.key === Qt.Key_Right) {
                            event.accepted = true;
                            controller.selectedIndex = clamp(controller.selectedIndex + 1);
                            Qt.callLater(ensureSelectedVisible);
                            return;
                        }
                    }
                }
            }
        }

        Flickable {
            Layout.fillWidth: true
            Layout.preferredHeight: 34
            Layout.bottomMargin: 2

            visible: !root.commandMode
            clip: true

            contentWidth: chipRow.implicitWidth
            contentHeight: height

            Row {
                id: chipRow
                height: parent.height
                spacing: 8

                Repeater {
                    model: root.chipModel
                    delegate: Launcher.Chip {
                        text: modelData.label || ""
                        icon: modelData.icon || ""
                        selected: controller.activeTag === (modelData.key || "All")
                        onClicked: {
                            controller.activeTag = modelData.key || "All";
                            controller.selectedIndex = 0;
                            Qt.callLater(ensureSelectedVisible);
                        }
                    }
                }
            }
        }

        PinnedStrip {
            Layout.fillWidth: true
            visible: !root.commandMode && root.trimmedQuery.length === 0 && pinnedEntries.length > 0
            controller: root.controller
            entries: pinnedEntries
            onLaunch: entry => root.controller.launch(entry)
        }

        ListView {
            id: list
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            model: rowCount()

            // more space between entries
            spacing: 12

            ScrollBar.vertical: ScrollBar {}

            delegate: Item {
                width: list.width
                height: 88

                readonly property int leftIdx: index * 2
                readonly property int rightIdx: leftIdx + 1

                readonly property var leftItem: (results.values && leftIdx < results.values.length) ? results.values[leftIdx] : null
                readonly property var rightItem: (results.values && rightIdx < results.values.length) ? results.values[rightIdx] : null

                RowLayout {
                    anchors.fill: parent
                    // more space between columns
                    spacing: 16

                    AppEntryDelegate {
                        Layout.fillWidth: true
                        item: leftItem
                        itemIndex: leftIdx
                        controller: root.controller
                        current: root.controller.selectedIndex === leftIdx
                        visible: leftItem !== null
                        onActivated: it => root.controller.launch(it)
                    }

                    AppEntryDelegate {
                        Layout.fillWidth: true
                        item: rightItem
                        itemIndex: rightIdx
                        controller: root.controller
                        current: root.controller.selectedIndex === rightIdx
                        visible: rightItem !== null
                        onActivated: it => root.controller.launch(it)
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 22

            Label {
                Layout.fillWidth: true
                color: Launcher.Palette.subtext0
                opacity: 0.95
                font.family: root.uiFamily
                font.pixelSize: root.footerSize

                text: {
                    const n = results.values ? results.values.length : 0;
                    if (root.commandMode)
                        return `${n} item(s) • Enter to run • Esc to close`;
                    return n > 0 ? `${n} result(s) • Enter to launch • Ctrl+P pin • Right-click pin • Esc to close` : "No results • Esc to close";
                }
            }
        }
    }
}
