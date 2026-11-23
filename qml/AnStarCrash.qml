import QtQuick

// 黯星：巨大行星撞击目标。纯 QML 绘制，无外部图片依赖。
// 触发：room:doSuperLightBox("packages/tianzong/qml/AnStarCrash.qml", data, pause, fade, true)
// data 可选：xRatio / yRatio 调整撞击点（0~1，默认居中）。
Item {
  id: root
  anchors.fill: parent
  clip: true

  property real hitX: 0.5
  property real hitY: 0.52
  property int planetSize: Math.min(width, height) * 0.6

  function loadData(data) {
    if (!data) return;
    if (data.xRatio !== undefined) hitX = data.xRatio;
    if (data.yRatio !== undefined) hitY = data.yRatio;
  }

  property real tx: width * hitX
  property real ty: height * hitY

  // 背景压暗
  Rectangle {
    anchors.fill: parent
    color: "#d005030f"
    opacity: 0
    NumberAnimation on opacity { from: 0; to: 1; duration: 260; running: true }
  }

  // 坠落行星
  Rectangle {
    id: planet
    width: planetSize; height: planetSize
    x: root.tx - width / 2
    y: -width * 1.5
    radius: width / 2
    opacity: 0
    z: 2
    gradient: Gradient {
      GradientStop { position: 0.0; color: "#a8ecff" }
      GradientStop { position: 0.35; color: "#3a9fd8" }
      GradientStop { position: 0.72; color: "#5b2a8c" }
      GradientStop { position: 1.0; color: "#160924" }
    }
    border.color: "#d6f6ff"
    border.width: 3
    Rectangle {
      width: parent.width * 0.32; height: parent.height * 0.18
      x: parent.width * 0.18; y: parent.height * 0.26
      radius: width / 2; color: "#2b6fa0"; opacity: 0.55
    }
    Rectangle {
      width: parent.width * 0.22; height: parent.height * 0.14
      x: parent.width * 0.56; y: parent.height * 0.52
      radius: width / 2; color: "#8a45bd"; opacity: 0.5
    }
    // 拖尾
    Rectangle {
      width: parent.width * 0.46; height: parent.height * 1.2
      x: parent.width * 0.27; y: -height * 0.95
      gradient: Gradient {
        GradientStop { position: 0.0; color: "#00000000" }
        GradientStop { position: 1.0; color: "#ff9a3caa" }
      }
    }
  }

  // 撞击闪光
  Rectangle {
    id: flash
    width: root.width * 1.8; height: root.height * 1.8
    x: root.tx - width / 2; y: root.ty - height / 2
    radius: width / 2
    opacity: 0
    z: 5
    gradient: Gradient {
      GradientStop { position: 0.0; color: "#ffffffff" }
      GradientStop { position: 0.35; color: "#ffd2a0dd" }
      GradientStop { position: 1.0; color: "#ff5a0000" }
    }
  }

  // 冲击波环 A
  Rectangle {
    id: ringA
    width: 10; height: 10
    x: root.tx - width / 2; y: root.ty - height / 2
    radius: width / 2
    color: "transparent"; border.color: "#fff2c8"; border.width: 10
    opacity: 0; z: 4
  }
  // 冲击波环 B
  Rectangle {
    id: ringB
    width: 10; height: 10
    x: root.tx - width / 2; y: root.ty - height / 2
    radius: width / 2
    color: "transparent"; border.color: "#9be8ff"; border.width: 7
    opacity: 0; z: 4
  }

  // 碎片簇：围绕撞击点环形排布，整体放大实现四散
  Item {
    id: burst
    x: root.tx; y: root.ty
    width: 0; height: 0
    opacity: 0; z: 4
    scale: 0.2
    Repeater {
      model: 12
      Rectangle {
        width: 15; height: 15; radius: 7
        x: Math.cos((modelData / 12) * Math.PI * 2) * 90 - width / 2
        y: Math.sin((modelData / 12) * Math.PI * 2) * 90 - height / 2
        color: modelData % 2 === 0 ? "#ffce7a" : "#9fe0ff"
      }
    }
  }

  SequentialAnimation {
    id: anim
    running: true

    // 行星加速坠落
    ScriptAction { script: planet.opacity = 1 }
    PropertyAnimation {
      target: planet; property: "y"
      from: -planetSize * 1.5
      to: root.ty - planetSize / 2
      duration: 620
      easing.type: Easing.InQuad
    }

    // 撞击瞬间
    ParallelAnimation {
      ScriptAction { script: {
        flash.opacity = 1;
        ringA.opacity = 1; ringA.width = 10; ringA.height = 10;
        ringA.x = root.tx - 5; ringA.y = root.ty - 5;
        ringB.opacity = 1; ringB.width = 10; ringB.height = 10;
        ringB.x = root.tx - 5; ringB.y = root.ty - 5;
        burst.opacity = 1; burst.scale = 0.2;
      } }
      PropertyAnimation { target: flash; property: "opacity"; to: 0; duration: 560 }
      PropertyAnimation { target: planet; property: "opacity"; to: 0; duration: 260 }
      PropertyAnimation { target: ringA; property: "width"; to: root.width * 1.2; duration: 640; easing.type: Easing.OutQuad }
      PropertyAnimation { target: ringA; property: "height"; to: root.width * 1.2; duration: 640; easing.type: Easing.OutQuad }
      PropertyAnimation { target: ringA; property: "opacity"; to: 0; duration: 640 }
      PropertyAnimation { target: ringB; property: "width"; to: root.width * 0.9; duration: 780; easing.type: Easing.OutQuad }
      PropertyAnimation { target: ringB; property: "height"; to: root.width * 0.9; duration: 780; easing.type: Easing.OutQuad }
      PropertyAnimation { target: ringB; property: "opacity"; to: 0; duration: 780 }
      PropertyAnimation { target: burst; property: "scale"; to: 2.4; duration: 700; easing.type: Easing.OutQuad }
      PropertyAnimation { target: burst; property: "opacity"; to: 0; duration: 700 }
      // 屏幕震动
      SequentialAnimation {
        PropertyAnimation { target: root; property: "x"; from: 0; to: 16; duration: 60 }
        PropertyAnimation { target: root; property: "x"; from: 16; to: -12; duration: 90 }
        PropertyAnimation { target: root; property: "x"; from: -12; to: 8; duration: 70 }
        PropertyAnimation { target: root; property: "x"; from: 8; to: 0; duration: 60 }
      }
    }

    PauseAnimation { duration: 220 }
    PropertyAnimation { target: root; property: "opacity"; to: 0; duration: 320 }

    onFinished: { roomScene.bigAnim.source = ""; }
  }
}
