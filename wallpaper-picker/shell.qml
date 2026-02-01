import QtQuick
import Quickshell
import "modules/wallpaper" as Wallpaper

ShellRoot {
  id: root

  Wallpaper.WallpaperPicker {
    id: picker
    wallpapersDir: "~/Pictures/Wallpapers"
    limit: 25
    onDismissed: Qt.quit() 
  }

  Component.onCompleted: picker.show()
}
