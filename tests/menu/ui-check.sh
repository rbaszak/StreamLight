#!/usr/bin/env bash
set -euo pipefail
pacman -U --noconfirm "/out/$(cat /out/current-package.txt)"
export QT_QPA_PLATFORM=xcb LIBGL_ALWAYS_SOFTWARE=1
export SDL_AUDIODRIVER=disk SDL_AUDIO_DISK_OUTPUT_FILE=/out/menu-audio.raw
timeout 35s xvfb-run -a -s '-screen 0 1280x720x24' bash -c '
    streamlight > /out/menu-ui.log 2>&1 &
    app_pid=$!
    trap "kill $app_pid 2>/dev/null || true" EXIT
    sleep 4
    xdotool key Escape
    sleep 1
    xdotool key s
    sleep 2
    xdotool mousemove 700 109 click 1
    sleep 1
    ffmpeg -v error -f x11grab -video_size 1280x720 -i "$DISPLAY" \
        -frames:v 1 -update 1 -y /out/menu-settings.png
    xdotool key Tab Right Down Up Return
    sleep 1
    kill -0 "$app_pid"
'
test -s /out/menu-audio.raw
if grep -Ei 'failed to load component|is not installed|is not a type|ReferenceError|TypeError|Cannot load library' /out/menu-ui.log; then
    exit 1
fi
