import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import qs.Commons
import qs.Ui

Panel {
  id: root
  moduleName: "levi.youtube-music"
  ipcTarget: "levi.youtube-music"

  readonly property var players: Mpris.players ? Mpris.players.values : []
  property var player: null

  function isBrowser(candidate) {
    var identity = String(candidate && candidate.identity || "").toLowerCase()
    return identity === "chromium"
      || identity.indexOf("mozilla zen") !== -1
      || identity.indexOf("firefox") !== -1
  }

  function isYoutubeMusic(candidate) {
    if (!candidate) return false
    var metadata = candidate.metadata || {}
    var url = String(metadata["xesam:url"] || "").toLowerCase()
    var identity = String(candidate.identity || "").toLowerCase()
    return identity.indexOf("youtube music") !== -1
      || url.indexOf("music.youtube.com") !== -1
      || (isBrowser(candidate) && candidate.isPlaying)
  }

  function selectPlayer() {
    for (var i = 0; i < players.length; i++) {
      var candidate = players[i]
      if (isYoutubeMusic(candidate) && candidate.isPlaying) {
        player = candidate
        return
      }
    }
    if (player && players.indexOf(player) !== -1) return
    player = null
  }

  Component.onCompleted: selectPlayer()
  onPlayersChanged: selectPlayer()

  Instantiator {
    model: root.players
    delegate: Connections {
      required property var modelData
      target: modelData
      function onIsPlayingChanged() { root.selectPlayer() }
    }
  }

  readonly property bool playing: player && player.playbackState === MprisPlaybackState.Playing
  // Quickshell's MPRIS player exposes trackArtUrl. Keep artUrl as a fallback
  // for older implementations that used that property name.
  readonly property string artUrl: player ? (player.trackArtUrl || player.artUrl || "") : ""
  readonly property string artistName: player ? (player.trackArtist || "") : ""
  readonly property string trackTitle: player ? (player.trackTitle || "Untitled track") : ""
  readonly property string albumName: player ? (player.trackAlbum || "") : ""

  readonly property color contentForeground: bar ? bar.barForeground : Color.foreground
  readonly property color dimForeground: Qt.darker(contentForeground, 1.45)
  readonly property color subtleFill: Style.normalFillFor(contentForeground, Color.accent)
  readonly property color subtleBorder: Style.normalBorderFor(contentForeground, Color.accent)
  readonly property string contentFontFamily: bar ? bar.fontFamily : Style.font.family

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  Timer {
    interval: 1000
    running: root.playing
    repeat: true
    onTriggered: if (root.player) root.player.positionChanged()
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰝚"
    active: false
    useActiveColor: false
    foreground: root.playing ? root.contentForeground : Qt.darker(root.contentForeground, 1.9)
    tooltipText: root.player ? (root.trackTitle + (root.artistName ? " — " + root.artistName : "")) : "YouTube Music"

    onPressed: function(buttonCode) {
      if (buttonCode === Qt.MiddleButton && root.player) root.player.togglePlaying()
      else root.toggle()
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    centerOnBar: true
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(root.player ? 348 : 238))
    contentHeight: panel.fittedContentHeight(contentColumn.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent

      onMoveRequested: function(dx, dy) {
        if (dx > 0 && root.player && root.player.canGoNext) root.player.next()
        else if (dx < 0 && root.player && root.player.canGoPrevious) root.player.previous()
      }
      onActivateRequested: if (root.player) root.player.togglePlaying()
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }
      onTextKey: function(text) {
        if (text === " " && root.player) root.player.togglePlaying()
        else if (text === "n" && root.player && root.player.canGoNext) root.player.next()
        else if (text === "p" && root.player && root.player.canGoPrevious) root.player.previous()
      }

      Column {
        id: contentColumn
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: Style.space(10)

        Row {
          visible: root.player !== null
          width: parent.width
          spacing: Style.space(12)

          Rectangle {
            id: cover
            width: Style.space(92)
            height: width
            radius: Style.cornerRadius
            color: root.subtleFill
            border.width: Math.max(1, Style.space(1))
            border.color: root.subtleBorder
            clip: true

            Text {
              anchors.centerIn: parent
              text: "󰝚"
              color: Color.accent
              opacity: 0.42
              font.family: root.contentFontFamily
              font.pixelSize: Style.font.displayLarge
            }

            Image {
              id: albumArt
              anchors.fill: parent
              visible: root.artUrl !== "" && status !== Image.Error
              source: root.artUrl
              sourceSize.width: Style.space(220)
              sourceSize.height: Style.space(220)
              fillMode: Image.PreserveAspectCrop
              asynchronous: true
              cache: true
            }
          }

          Column {
            width: parent.width - cover.width - parent.spacing
            anchors.verticalCenter: cover.verticalCenter
            spacing: Style.space(4)

            Text {
              width: parent.width
              text: root.trackTitle
              color: root.contentForeground
              font.family: root.contentFontFamily
              font.pixelSize: Style.font.subtitle
              font.bold: true
              wrapMode: Text.Wrap
              elide: Text.ElideRight
              maximumLineCount: 2
            }

            Text {
              width: parent.width
            text: root.artistName || "YouTube Music"
              color: root.contentForeground
              opacity: 0.82
              font.family: root.contentFontFamily
              font.pixelSize: Style.font.body
              elide: Text.ElideRight
              maximumLineCount: 1
            }

            Text {
              visible: root.albumName !== ""
              width: parent.width
              text: root.albumName
              color: root.dimForeground
              font.family: root.contentFontFamily
              font.pixelSize: Style.font.caption
              elide: Text.ElideRight
              maximumLineCount: 1
            }
          }
        }

        Row {
          visible: root.player === null
          width: parent.width
          height: Style.space(38)
          spacing: Style.space(10)

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "󰝚"
            color: root.dimForeground
            font.family: root.contentFontFamily
            font.pixelSize: Style.font.icon
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "YouTube Music is idle"
            color: root.dimForeground
            font.family: root.contentFontFamily
            font.pixelSize: Style.font.body
          }
        }

        Column {
          visible: root.player !== null
          width: parent.width
          spacing: Style.space(2)

          PanelSlider {
            id: progressSlider
            width: parent.width
            bar: root.bar
            minimum: 0
            maximum: root.player ? Math.max(1, root.player.length) : 1
            value: root.player ? root.player.position : 0
            step: 5
            trackHeight: Math.max(3, Style.space(3))
            knobSize: Style.space(10)
            onReleased: function(nextPosition) {
              if (root.player && root.player.length > 0) root.player.position = nextPosition
            }
          }

          RowLayout {
            width: parent.width

            Text {
              text: root.player ? root.formatTime(progressSlider.dragging ? progressSlider.liveValue : root.player.position) : "0:00"
              color: root.dimForeground
              font.family: root.contentFontFamily
              font.pixelSize: Style.font.caption
            }

            Item { Layout.fillWidth: true }

            Text {
              text: root.player ? root.formatTime(root.player.length) : "0:00"
              color: root.dimForeground
              font.family: root.contentFontFamily
              font.pixelSize: Style.font.caption
            }
          }
        }

        Item {
          visible: root.player !== null
          width: parent.width
          height: Style.space(34)

          Row {
            anchors.centerIn: parent
            spacing: Style.space(14)

            PanelActionButton {
              anchors.verticalCenter: parent.verticalCenter
              iconText: "\uf048"
              tooltipText: "Previous track"
              foreground: root.contentForeground
              hoverColor: Color.accent
              fontFamily: root.contentFontFamily
              fontSize: Style.font.body
              size: Style.space(28)
              bordered: false
              enabled: root.player && root.player.canGoPrevious
              onClicked: if (root.player) root.player.previous()
            }

            PanelActionButton {
              anchors.verticalCenter: parent.verticalCenter
              iconText: root.playing ? "\uf04c" : "\uf04b"
              tooltipText: root.playing ? "Pause" : "Play"
              foreground: Color.accent
              hoverColor: Color.accent
              fontFamily: root.contentFontFamily
              fontSize: Style.font.iconLarge
              size: Style.space(34)
              bordered: false
              enabled: root.player && (root.player.canTogglePlaying || root.player.canPlay || root.player.canPause || root.player.canControl)
              onClicked: if (root.player) root.player.togglePlaying()
            }

            PanelActionButton {
              anchors.verticalCenter: parent.verticalCenter
              iconText: "\uf051"
              tooltipText: "Next track"
              foreground: root.contentForeground
              hoverColor: Color.accent
              fontFamily: root.contentFontFamily
              fontSize: Style.font.body
              size: Style.space(28)
              bordered: false
              enabled: root.player && root.player.canGoNext
              onClicked: if (root.player) root.player.next()
            }
          }
        }
      }
    }
  }

  function formatTime(seconds) {
    if (!seconds || seconds <= 0) return "0:00"
    var totalSeconds = Math.floor(seconds)
    var minutes = Math.floor(totalSeconds / 60)
    var remainingSeconds = totalSeconds % 60
    return minutes + ":" + (remainingSeconds < 10 ? "0" : "") + remainingSeconds
  }
}
