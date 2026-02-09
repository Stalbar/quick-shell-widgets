pragma Singleton

import QtQuick
import Quickshell

import "." as Launcher

QtObject {
    id: root

    function build(term, prefix) {
        const t = (term || "").trim();
        const q = t.toLowerCase();

        const out = [];

        if (t.length > 0) {
            if (prefix === ":") {
                out.push({
                    kind: "command",
                    id: "run-term",
                    name: "Run in terminal",
                    subtitle: t,
                    icon: "utilities-terminal",
                    command: ["kitty", "-e", "sh", "-lc", t],
                    _record: t
                });
            } else {
                out.push({
                    kind: "command",
                    id: "run-shell",
                    name: "Run",
                    subtitle: t,
                    icon: "system-run",
                    command: ["sh", "-c", t],
                    _record: t
                });
            }
        } else {
            out.push({
                kind: "command",
                id: "hint",
                name: "Type a command",
                subtitle: (prefix === ":" ? ": pacman -Syu" : "> echo hello"),
                icon: "system-run",
                command: null
            });
        }

        const hist = (Launcher.LauncherState && Launcher.LauncherState.cmdHistory) ? Launcher.LauncherState.cmdHistory : [];
        for (let i = 0; i < hist.length && out.length < 12; i++) {
            const h = String(hist[i] || "").trim();
            if (!h)
                continue;
            if (q && h.toLowerCase().indexOf(q) < 0)
                continue;

            out.push({
                kind: "command",
                id: "hist:" + i,
                name: "History",
                subtitle: h,
                icon: "document-open-recent",
                command: (prefix === ":") ? ["kitty", "-e", "sh", "-lc", h] : ["sh", "-c", h],
                _record: h
            });
        }

        const base = [
            {
                id: "lock",
                name: "Lock",
                subtitle: "hyprlock",
                icon: "system-lock-screen",
                command: ["sh", "-c", "hyprlock"]
            },
            {
                id: "logout",
                name: "Logout",
                subtitle: "hyprctl dispatch exit",
                icon: "system-log-out",
                command: ["hyprctl", "dispatch", "exit"]
            },
            {
                id: "reload",
                name: "Reload WM",
                subtitle: "hyprctl reload",
                icon: "view-refresh",
                command: ["hyprctl", "reload"]
            },
            {
                id: "terminal",
                name: "Kitty",
                subtitle: "Open terminal",
                icon: "utilities-terminal",
                command: ["kitty"]
            }
        ];

        for (const c of base) {
            const hay = (c.name + " " + (c.subtitle || "")).toLowerCase();
            if (!q || hay.indexOf(q) >= 0) {
                out.push({
                    kind: "command",
                    id: "builtin:" + c.id,
                    name: c.name,
                    subtitle: c.subtitle,
                    icon: c.icon,
                    command: c.command
                });
            }
        }

        return out;
    }

    function run(item) {
        if (!item)
            return;
        if (!item.command)
            return;

        Quickshell.execDetached(item.command);

        if (item._record && Launcher.LauncherState)
            Launcher.LauncherState.recordCommand(String(item._record));
    }
}
