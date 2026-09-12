#!/usr/bin/env bash
set -euo pipefail
# Isolated container-only fixture: no real host, pairing keys, or user settings.
pacman -U --noconfirm "/out/$(cat /out/current-package.txt)"
mkdir -p /root/.config/FoggyBytes
cat > /root/.config/FoggyBytes/StreamLight.conf <<'INI'
[General]
videodec=2
mdns=false

[hosts]
size=1
1\hostname=Offline QA host
1\uuid=qa-host
1\manualaddress=192.0.2.10
1\streamtweakenabled=false
INI
export QT_QPA_PLATFORM=xcb LIBGL_ALWAYS_SOFTWARE=1 SDL_AUDIODRIVER=dummy
timeout 40s xvfb-run -a -s '-screen 0 1280x720x24' bash -c '
    streamlight > /out/default-host-ui.log 2>&1 &
    app_pid=$!
    trap "kill $app_pid 2>/dev/null || true" EXIT
    sleep 4
    xdotool key Right Right Return
    sleep 1
    ffmpeg -v error -f x11grab -video_size 1280x720 -i "$DISPLAY" \
        -frames:v 1 -update 1 -y /out/default-host-options.png
    xdotool key Return
    sleep 1
    grep -q "defaultHost=qa-host/" /root/.config/FoggyBytes/StreamLight.conf || exit 1
    kill "$app_pid"
    wait "$app_pid" || true
    streamlight >> /out/default-host-ui.log 2>&1 &
    app_pid=$!
    trap "kill $app_pid 2>/dev/null || true" EXIT
    sleep 10
    kill -0 "$app_pid" || exit 1
    ffmpeg -v error -f x11grab -video_size 1280x720 -i "$DISPLAY" \
        -frames:v 1 -update 1 -y /out/default-host-offline.png
    xdotool key Right Right Return
    sleep 1
    ffmpeg -v error -f x11grab -video_size 1280x720 -i "$DISPLAY" \
        -frames:v 1 -update 1 -y /out/default-host-clear.png
    xdotool key Return
    sleep 1
    grep -q "defaultHost=$" /root/.config/FoggyBytes/StreamLight.conf || exit 1
'
if grep -Ei 'failed to load component|is not installed|is not a type|ReferenceError|TypeError' /out/default-host-ui.log; then
    exit 1
fi
echo 'PASS: set default host, restart offline, clear default host.'
