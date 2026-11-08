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

  // Stands in for a Quickshell Toplevel: a QObject with a title.
  Component {
    id: fakeWindow
    QtObject { property string title }
  }

  function chromium(title, album) {
    return {
      identity: "Chromium",
      trackTitle: title,
      isPlaying: true,
      metadata: { "xesam:title": title, "xesam:album": album }
    }
  }

  Component.onCompleted: {
    var podcast = chromium("The S in PHP is for Security", "")
    var cases = [
      // A podcast episode publishes an empty album; the web app window names it.
      ["podcast with YouTube Music window", podcast,
        ["The S in PHP is for Security | YouTube Music"], true],
      // A browser tab focused on YouTube Music shows the page title too.
      ["podcast in focused browser tab", podcast,
        ["The S in PHP is for Security | YouTube Music - Chromium"], true],
      // Without such a window an empty album is still not enough.
      ["podcast without window", podcast,
        ["Pack drafter - Chromium"], false],
      // A regular video in another tab of the same browser process must not be
      // claimed just because a YouTube Music window is open.
      ["other tab while YouTube Music is open", chromium("Some video", ""),
        ["Earlier song | YouTube Music", "Some video - YouTube - Chromium"], false],
      // Existing album fallback keeps working with no window at all.
      ["song with album, no window", chromium("A song", "An album"), [], true],
      // Non-browser players are not matched by window title.
      ["non-browser player", {
        identity: "Spotify", trackTitle: "A song", isPlaying: true,
        metadata: { "xesam:album": "" }
      }, ["A song | YouTube Music"], false]
    ]

    var failed = 0
    for (var i = 0; i < cases.length; i++) {
      panel.toplevels = cases[i][2].map(function(t) { return fakeWindow.createObject(null, { title: t }) })
      var got = panel.isYoutubeMusic(cases[i][1])
      if (got !== cases[i][3]) {
        failed++
        console.log("FAIL " + cases[i][0] + ": expected " + cases[i][3] + ", got " + got)
      }
    }
    console.log(failed === 0 ? "TEST_PASS" : "TEST_FAIL")
    Qt.quit()
  }
}
