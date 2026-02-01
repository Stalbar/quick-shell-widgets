pragma Singleton
import QtQuick
import "../theme" as Theme

QtObject {
  readonly property var outCubic: Easing.OutCubic
  readonly property var outQuint: Easing.OutQuint

  function scaleBehavior(targetObj, duration) {
    return Qt.createQmlObject(
      'import QtQuick; Behavior { NumberAnimation { duration: ' + duration + '; easing.type: Easing.OutQuint } }',
      targetObj
    );
  }
}
