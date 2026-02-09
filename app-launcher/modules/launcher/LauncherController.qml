import QtQuick
import Quickshell
import Quickshell.Hyprland

import "." as Launcher

Item {
    id: root
    visible: false
    width: 0
    height: 0

    property bool open: false
    property string query: ""
    property int selectedIndex: 0

    property int columns: 2
    property int maxResults: 140

    property string activeTag: "All"

    property var screen: null

    function pickFocusedScreen() {
        const screens = Quickshell.screens;
        if (!screens || screens.length === 0)
            return null;

        const mon = Hyprland.focusedMonitor;
        if (mon) {
            const hit = screens.filter(s => s.name === mon.name)[0];
            if (hit)
                return hit;
        }
        return screens[0];
    }

    function show() {
        Hyprland.refreshMonitors();
        screen = pickFocusedScreen();
        query = "";
        selectedIndex = 0;
        activeTag = "All";
        open = true;
    }

    function hide() {
        open = false;
    }
    function toggle() {
        open ? hide() : show();
    }

    function launch(item) {
        if (!item)
            return;

        if (item.kind === "command" || item.kind === "action") {
            Launcher.Commands.run(item);
            hide();
            return;
        }

        if (item.execute) {
            Launcher.LauncherState.recordLaunch(String(item.id || ""));
            item.execute();
            hide();
        }
    }

    Connections {
        target: Hyprland
        function onFocusedMonitorChanged() {
            if (root.open)
                root.screen = root.pickFocusedScreen();
        }
    }
}
