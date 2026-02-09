pragma Singleton

import QtQuick
import "." as Launcher

QtObject {
    readonly property var chips: ([
            {
                key: "All",
                label: "All",
                icon: "view-grid"
            },
            {
                key: "Pinned",
                label: "Pinned",
                icon: "emblem-favorite"
            },
            {
                key: "Frequent",
                label: "Frequent",
                icon: "view-history"
            },
            {
                key: "Terminal",
                label: "Terminal",
                icon: "utilities-terminal"
            },
            {
                key: "Browser",
                label: "Browser",
                icon: "web-browser"
            },
            {
                key: "Editor",
                label: "Editor",
                icon: "accessories-text-editor"
            },
            {
                key: "Dev",
                label: "Dev",
                icon: "applications-development"
            },
            {
                key: "Media",
                label: "Media",
                icon: "multimedia-player"
            },
            {
                key: "System",
                label: "System",
                icon: "preferences-system"
            }
        ])

    function _cats(entry) {
        const c = (entry && entry.categories) ? entry.categories : [];
        return (c || []).map(x => String(x));
    }

    function matches(entry, tagKey) {
        if (!entry)
            return false;
        if (!tagKey || tagKey === "All")
            return true;

        const id = String(entry.id || "");
        const name = String(entry.name || "").toLowerCase();
        const cats = _cats(entry);

        if (tagKey === "Pinned")
            return Launcher.LauncherState.isPinned(id);
        if (tagKey === "Frequent")
            return true;

        if (tagKey === "Terminal")
            return cats.indexOf("TerminalEmulator") >= 0 || name.indexOf("terminal") >= 0;

        if (tagKey === "Browser")
            return name.indexOf("firefox") >= 0 || name.indexOf("chrom") >= 0 || name.indexOf("browser") >= 0;

        if (tagKey === "Editor")
            return cats.indexOf("TextEditor") >= 0 || name.indexOf("code") >= 0 || name.indexOf("vim") >= 0 || name.indexOf("kate") >= 0;

        if (tagKey === "Dev")
            return cats.indexOf("Development") >= 0 || name.indexOf("qt") >= 0 || name.indexOf("idea") >= 0;

        if (tagKey === "Media")
            return cats.indexOf("AudioVideo") >= 0 || name.indexOf("mpv") >= 0 || name.indexOf("vlc") >= 0;

        if (tagKey === "System")
            return cats.indexOf("System") >= 0 || cats.indexOf("Settings") >= 0 || name.indexOf("settings") >= 0;

        return true;
    }
}
