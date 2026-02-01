import QtQuick

Item {
  id: root
  anchors.fill: parent
  opacity: 0.05
  visible: true

  Canvas {
    anchors.fill: parent
    onPaint: {
      const ctx = getContext("2d");
      const w = width, h = height;
      const img = ctx.createImageData(w, h);
      for (let i = 0; i < img.data.length; i += 4) {
        const v = Math.floor(Math.random() * 255);
        img.data[i] = v;
        img.data[i+1] = v;
        img.data[i+2] = v;
        img.data[i+3] = 255;
      }
      ctx.putImageData(img, 0, 0);
    }
  }

  Timer {
    interval: 900
    running: true
    repeat: true
    onTriggered: root.children[0].requestPaint()
  }
}
