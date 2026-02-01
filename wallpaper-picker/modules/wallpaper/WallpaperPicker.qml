import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

import "../../theme" as Theme
import "../../ui" as UI
import "."

PanelWindow {
    id: picker

    property bool open: false
    property string wallpapersDir: "~/Pictures/Wallpapers"
    property int limit: 50
    property int cardW: 342
    property int cardH: 140
    property int shelfH: 38
    property int overlap: 28
    signal selected(string path)
    signal dismissed

    property real openT: open ? 1 : 0
    Behavior on openT {
        NumberAnimation {
            duration: Theme.Tokens.durSlow
            easing.type: Easing.OutCubic
        }
    }

    anchors {
        bottom: true
        left: true
        right: true
    }

    margins {
        bottom: -implicitHeight + (implicitHeight * openT)
        left: 388
        right: 388
    }
    implicitHeight: cardH + shelfH - overlap + 18
    color: "transparent"

    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.namespace: "wallpaper_picker"
    WlrLayershell.exclusionMode: WlrLayershell.None
    WlrLayershell.keyboardFocus: WlrLayershell.OnDemand
    focusable: true

    Behavior on margins.bottom {
        NumberAnimation {
            duration: Theme.Tokens.durSlow
            easing.type: Easing.OutCubic
        }
    }

    function show() {
        open = true;
        store.folder = wallpapersDir;
        store.limit = limit;
        store.reload();
        panel.forceActiveFocus();
        keyCatcher.forceActiveFocus();
    }

    function hide() {
        open = false;
        dismissed();
    }

    WallpaperStore {
        id: store
        onLoaded: {
            view.currentIndex = 0;
            view.positionViewAtIndex(0, ListView.Center);
        }
    }

    Item {
        id: surface
        anchors.fill: parent
        clip: false
        opacity: openT
        scale: 0.98 + openT * 0.02
        transformOrigin: Item.Bottom

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.Tokens.durMed
            }
        }
        Behavior on scale {
            NumberAnimation {
                duration: Theme.Tokens.durSlow
                easing.type: Easing.OutCubic
            }
        }

        UI.AcrylicPanel {
            id: shelf
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            implicitHeight: shelfH
            radius: Theme.Tokens.radiusLg
            glow: true

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: 1
                color: Qt.rgba(1, 1, 1, 0.10)
                opacity: 0.7
            }
        }

        ListView {
            id: view
            anchors.left: parent.left
            anchors.right: parent.right

            anchors.bottom: shelf.top
            anchors.bottomMargin: -overlap

            height: cardH
            clip: false

            orientation: ListView.Horizontal
            spacing: 54
            leftMargin: 20
            rightMargin: 20
            boundsBehavior: Flickable.StopAtBounds
            model: store.loading ? 8 : store.model

            snapMode: ListView.SnapToItem
            highlightRangeMode: ListView.StrictlyEnforceRange
            preferredHighlightBegin: width / 2 - (cardW / 2)
            preferredHighlightEnd: width / 2 - (cardW / 2)

            property int hoveredIndex: -1

            Behavior on contentX {
                NumberAnimation {
                    duration: Theme.Tokens.durMed
                    easing.type: Easing.OutCubic
                }
            }

            WheelHandler {
                target: view
                rotationScale: 20.0
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                onWheel: event => {
                    const delta = event.angleDelta.y * -0.5;
                    const maxX = Math.max(0, view.contentWidth - view.width);
                    view.contentX = Math.max(0, Math.min(view.contentX + delta, maxX));
                }
            }

            delegate: Item {
                width: cardW
                height: cardH
                z: store.loading ? 0 : card.z

                Rectangle {
                    id: skeleton
                    anchors.fill: parent
                    radius: Theme.Tokens.radiusMd
                    color: Theme.CatppuccinMocha.surface
                    visible: store.loading

                    Rectangle {
                        id: shimmer
                        width: skeleton.width * 0.35
                        height: skeleton.height
                        x: -width
                        color: Qt.rgba(1, 1, 1, 0.06)
                        rotation: 12

                        SequentialAnimation on x {
                            running: store.loading
                            loops: Animation.Infinite
                            NumberAnimation {
                                from: -shimmer.width
                                to: skeleton.width + shimmer.width
                                duration: 950
                                easing.type: Easing.InOutCubic
                            }
                        }
                    }
                }

                WallpaperCard {
                    id: card
                    anchors.fill: parent
                    visible: !store.loading

                    path: store.loading ? "" : model.path
                    dimmed: view.hoveredIndex !== -1 && view.hoveredIndex !== index
                    selected: view.currentIndex === index

                    onClicked: p => picker.selected(p)
                    onHovered: inside => {
                        view.hoveredIndex = inside ? index : -1;
                        if (inside)
                            view.currentIndex = index;
                    }
                }
            }
        }

        Item {
            id: keyCatcher
            anchors.fill: parent
            focus: true

            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape) {
                    picker.hide();
                    event.accepted = true;
                    return;
                }

                if (event.key === Qt.Key_Left) {
                    view.currentIndex = Math.max(0, view.currentIndex - 1);
                    view.positionViewAtIndex(view.currentIndex, ListView.Visible);
                    event.accepted = true;
                    return;
                }

                if (event.key === Qt.Key_Right) {
                    view.currentIndex = Math.min(view.count - 1, view.currentIndex + 1);
                    view.positionViewAtIndex(view.currentIndex, ListView.Visible);
                    event.accepted = true;
                    return;
                }

                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    if (!store.loading) {
                        const item = store.model.get(view.currentIndex);
                        if (item && item.path)
                            picker.selected(item.path);
                    }
                    event.accepted = true;
                    return;
                }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.AllButtons
                onPressed: keyCatcher.forceActiveFocus()
                hoverEnabled: false
            }
        }
    }

    Process {
        id: swwwSetter
    }

    onSelected: path => {
        const transitions = ["simple", "fade", "left", "right", "top", "bottom", "wipe", "wave", "grow", "center", "any", "outer", "pixel", "wheel"];
        const selectedTransition = transitions[Math.floor(Math.random() * transitions.length)];
        swwwSetter.command = ["swww", "img", path, "--transition-type", selectedTransition, "--transition-fps", "144", "--transition-duration", "1.2"];
        swwwSetter.running = true;
        toast("Applied ✓");
    }
    property string toastText: ""
    property real toastT: 0

    function toast(msg) {
        toastText = msg;
        toastT = 1;
        toastAnim.restart();
    }

    SequentialAnimation {
        id: toastAnim
        NumberAnimation {
            target: picker
            property: "toastT"
            to: 1
            duration: 0
        }
        PauseAnimation {
            duration: 900
        }
        NumberAnimation {
            target: picker
            property: "toastT"
            to: 0
            duration: 320
            easing.type: Easing.OutCubic
        }
    }
}
