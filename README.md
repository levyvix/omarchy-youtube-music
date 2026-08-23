# Omarchy YouTube Music

A YouTube Music controller for the Omarchy Quickshell bar.

The plugin reads the browser's live MPRIS player. It shows the current track,
album art, artist, album, progress, and playback controls in a popup panel.

## Requirements

- Omarchy Quattro with Quickshell
- YouTube Music open in Brave, Google Chrome, Chromium, Firefox, or Zen
- A browser that exposes the current media tab through MPRIS

The plugin does not start a background service, use browser automation, or
store account data. Browser MPRIS metadata can omit the page URL, so an active
Brave, Google Chrome, Chromium, Firefox, or Zen browser player is used as a
fallback when it is playing.

## Install

```sh
omarchy plugin add https://github.com/levyvix/omarchy-youtube-music.git --enable
```

Place it in the bar if needed:

```sh
omarchy bar move levi.youtube-music --section left
```

## Controls

- Left click the music icon to open or close the panel.
- Middle click toggles play/pause.
- `Space` toggles play/pause.
- `n` or Right arrow plays the next track.
- `p` or Left arrow plays the previous track.
- Drag the progress bar to seek.
- `Escape` closes the panel.

The panel keeps the last detected browser player while it remains connected,
so pausing a track does not make the panel appear idle.

## Validate locally

```sh
omarchy plugin validate .
qmllint -I "$OMARCHY_PATH/shell" Panel.qml
```

## Remove

```sh
omarchy plugin remove levi.youtube-music
```

## License

MIT. See [LICENSE](LICENSE).
