import QtQuick

QtObject {
  readonly property color rosewater: "#f5e0dc"
  readonly property color flamingo: "#f2cdcd"
  readonly property color pink: "#f5c2e7"
  readonly property color mauve: "#cba6f7"
  readonly property color red: "#f38ba8"
  readonly property color maroon: "#eba0ac"
  readonly property color peach: "#fab387"
  readonly property color yellow: "#f9e2af"
  readonly property color green: "#a6e3a1"
  readonly property color teal: "#94e2d5"
  readonly property color sky: "#89dceb"
  readonly property color sapphire: "#74c7ec"
  readonly property color blue: "#89b4fa"
  readonly property color lavender: "#b4befe"

  readonly property color text: "#cdd6f4"
  readonly property color subtext1: "#bac2de"
  readonly property color subtext0: "#a6adc8"

  readonly property color overlay2: "#9399b2"
  readonly property color overlay1: "#7f849c"
  readonly property color overlay0: "#6c7086"

  readonly property color surface2: "#585b70"
  readonly property color surface1: "#45475a"
  readonly property color surface0: "#313244"

  readonly property color base: "#1e1e2e"
  readonly property color mantle: "#181825"
  readonly property color crust: "#11111b"

  readonly property int radiusOuter: 22
  readonly property int radiusInner: 16
  readonly property int padding: 14
  readonly property int gap: 10

  readonly property color acrylicTint: Qt.rgba(0.117, 0.117, 0.180, 0.72)
  readonly property color acrylicOverlay: Qt.rgba(1, 1, 1, 0.06)
  readonly property color border: Qt.rgba(1, 1, 1, 0.10)

  readonly property color shadow: Qt.rgba(0, 0, 0, 0.45)

  readonly property color shadowStrong: Qt.rgba(0, 0, 0, 0.55)
  readonly property color shadowSoft: Qt.rgba(0, 0, 0, 0.35)
  readonly property color glowSoft: Qt.rgba(0.54, 0.70, 0.98, 0.18)
  readonly property color glowMauve: Qt.rgba(0.80, 0.65, 0.97, 0.18)

  readonly property int durFast: 120
  readonly property int durMed: 220
  readonly property int durSlow: 420
  readonly property int durBar: 520

  readonly property int easeOut: Easing.OutCubic
  readonly property int easeBack: Easing.OutBack
}
