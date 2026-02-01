import QtQuick
import Quickshell.Io

Item {
    id: store
    visible: false
    width: 0
    height: 0

    property string folder: "~/Pictures/Wallpapers"
    property int limit: 25

    property bool loading: false

    ListModel {
        id: wallpaperModel
    }
    property alias model: wallpaperModel

    signal loaded

    function reload() {
        loading = true;
        loader.running = false;   
        loader.running = true;
    }

    Process {
        id: loader
        running: false
        command: ["bash", "-lc", "DIR=$(eval echo \"" + store.folder + "\"); " + "find \"$DIR\" -type f \\( -iname '*.jpg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.jpeg' \\) | shuf -n " + store.limit]

        stdout: StdioCollector {
            onStreamFinished: {
                const out = (this.text || "").trim();
                const lines = out.length ? out.split("\n") : [];
                wallpaperModel.clear();

                for (let p of lines) {
                    p = p.trim();
                    if (p.length > 0)
                        wallpaperModel.append({
                            path: p
                        });
                }

                store.loading = false;
                loader.running = false;
                store.loaded();
            }
        }
    }
}
