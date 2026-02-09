pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root
    visible: false
    width: 0
    height: 0

    readonly property string stateFile: Quickshell.statePath("launcher-state.json")

    property alias pins: adapter.pins     
    property alias usage: adapter.usage        
    property alias cmdHistory: adapter.cmdHistory // list<string>

    FileView {
        id: store
        path: root.stateFile
        watchChanges: true

        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()

        JsonAdapter {
            id: adapter
            property list<string> pins: []
            property var usage: ({})
            property list<string> cmdHistory: []
        }
    }

    function isPinned(id) {
        if (!id)
            return false;
        return (pins || []).indexOf(id) >= 0;
    }

    function togglePin(id) {
        if (!id)
            return;
        const arr = (pins || []).slice();
        const i = arr.indexOf(id);
        if (i >= 0)
            arr.splice(i, 1);
        else
            arr.unshift(id);
        adapter.pins = arr;
    }

    function recordLaunch(desktopId) {
        if (!desktopId)
            return;
        const u = Object.assign({}, usage || {});
        u[desktopId] = (u[desktopId] || 0) + 1;
        adapter.usage = u;
    }

    function recordCommand(cmdLine) {
        const s = (cmdLine || "").trim();
        if (!s)
            return;

        const arr = (cmdHistory || []).slice();
        const i = arr.indexOf(s);
        if (i >= 0)
            arr.splice(i, 1);
        arr.unshift(s);

        while (arr.length > 30)
            arr.pop();
        adapter.cmdHistory = arr;
    }
}
