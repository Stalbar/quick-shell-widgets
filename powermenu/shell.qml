import QtQuick
import Quickshell

import "modules/powermenu" as PM

ShellRoot {
    PM.PowerMenuOverlay {
        centerIconText: ""
        fontFamily: "JetBrainsMono Nerd Font"

        PM.PowerAction {
            actionId: "lock"
            label: "Lock"
            iconText: "󰌾"
            command: "command -v hyprlock >/dev/null 2>&1 && hyprlock || loginctl lock-session"
            accent: "#89b4fa"
            neonIntensity: 1.0
            key: Qt.Key_L
        }

        PM.PowerAction {
            actionId: "logout"
            label: "Logout"
            iconText: "󰗽"
            command: "hyprctl dispatch exit"
            accent: "#f38ba8"
            neonIntensity: 0.35
            key: Qt.Key_E
        }

        PM.PowerAction {
            actionId: "suspend"
            label: "Suspend"
            iconText: "󰤄"
            command: "systemctl suspend"
            accent: "#94e2d5"
            neonIntensity: 0.35
            key: Qt.Key_U
        }

        PM.PowerAction {
            actionId: "hibernate"
            label: "Hibernate"
            iconText: "󰤁"
            command: "systemctl hibernate"
            accent: "#74c7ec"
            neonIntensity: 1.0
            key: Qt.Key_H
        }

        PM.PowerAction {
            actionId: "reboot"
            label: "Reboot"
            iconText: "󰜉"
            command: "systemctl reboot"
            accent: "#fab387"
            neonIntensity: 0.35
            key: Qt.Key_R
        }

        PM.PowerAction {
            actionId: "poweroff"
            label: "Shutdown"
            iconText: "󰐥"
            command: "systemctl poweroff"
            accent: "#cba6f7"
            neonIntensity: 0.35
            key: Qt.Key_P
        }
    }
}
