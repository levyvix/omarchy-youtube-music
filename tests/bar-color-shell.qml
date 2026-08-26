import QtQuick
import Quickshell
import "Plugin" as YoutubeMusic

ShellRoot {
  QtObject {
    id: testBar

    property color barForeground: "#111614"
    property color foreground: "#dce2f0"
    property color background: "#101010"
    property color urgent: "#ff0000"
    property string fontFamily: "monospace"
    property string position: "top"
    property int barSize: 32
    property bool vertical: false
    property bool foregroundAnimationEnabled: false
    property var activePopout: null
    property var clickTargets: []

    function hideTooltip() {}
    function showTooltip() {}
    function registerClickTarget() {}
    function unregisterClickTarget() {}
  }

  YoutubeMusic.Panel {
    id: panel
    bar: testBar
  }

  Component.onCompleted: {
    panel.player = null

    var button = null
    for (var i = 0; i < panel.children.length; i++) {
      if ("labelVisible" in panel.children[i]) {
        button = panel.children[i]
        break
      }
    }

    var barMatches = button
      && String(button.foreground) === String(testBar.barForeground)
    var popupMatches = String(panel.contentForeground) === String(testBar.foreground)
    console.log(barMatches && popupMatches ? "TEST_PASS" : "TEST_FAIL")
    if (!barMatches) console.log("bar foreground mismatch")
    if (!popupMatches) console.log("popup foreground mismatch")
    Qt.quit()
  }
}
