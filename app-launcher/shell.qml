import QtQuick
import Quickshell
import Quickshell.Io

import "./modules/launcher" as Launcher

ShellRoot {
    id: root

    Launcher.LauncherController {
        id: launcher
    }

    Launcher.AppLauncherOverlay {
        id: overlay
        controller: launcher
    }

    IpcHandler {
        target: "launcher"

        function show(): void {
            launcher.show();
        }
        function hide(): void {
            launcher.hide();
        }
        function toggle(): void {
            launcher.toggle();
        }

        function search(q: string): void {
            launcher.show();
            launcher.query = q;
            launcher.selectedIndex = 0;
        }
    }
}
