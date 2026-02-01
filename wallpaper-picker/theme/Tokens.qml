pragma Singleton
import QtQuick
import "."

QtObject {
  readonly property int radiusLg: 20
  readonly property int radiusMd: 12
  readonly property int stroke: 2

  readonly property real blurRadius: 28
  readonly property real tintOpacity: 0.55

  readonly property int durFast: 140
  readonly property int durMed: 260
  readonly property int durSlow: 520

  readonly property color bgTint: Qt.rgba(
    CatppuccinMocha.mauve.r, CatppuccinMocha.mauve.g, CatppuccinMocha.mauve.b, tintOpacity
  )
  readonly property color outline: CatppuccinMocha.cyan
  readonly property color focus: CatppuccinMocha.accent
}
