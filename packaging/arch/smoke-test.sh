#!/usr/bin/env bash
set -euo pipefail
# Run as root inside the builder image, with dist mounted at /out.
package=$(cat /out/current-package.txt)
pacman -U --noconfirm "/out/$package"
pacman -Qkk streamlight
ldd /usr/bin/streamlight > /out/ldd.txt
if grep -q 'not found' /out/ldd.txt; then
    cat /out/ldd.txt
    exit 1
fi
export QT_QPA_PLATFORM=xcb
export LIBGL_ALWAYS_SOFTWARE=1
xvfb-run -a streamlight --version > /out/version.txt 2>&1
set +e
timeout 45s xvfb-run -a -s '-screen 0 1280x720x24' bash -c '
    streamlight &
    app_pid=$!
    trap "kill $app_pid 2>/dev/null || true" EXIT
    sleep 20
    kill -0 "$app_pid" || exit 1
    ffmpeg -v error -f x11grab -video_size 1280x720 -i "$DISPLAY" \
        -frames:v 1 -update 1 -y /out/startup.png
    xdotool key Escape
    sleep 1
    xdotool key s
    sleep 2
    kill -0 "$app_pid" || exit 1
    ffmpeg -v error -f x11grab -video_size 1280x720 -i "$DISPLAY" \
        -frames:v 1 -update 1 -y /out/settings.png
    # At this fixed test resolution, enable normal frame pacing and scroll to
    # fractional V-Sync: the Windows-only row must remain disabled.
    xdotool mousemove 1195 585 click 1 mousemove 750 580 click --repeat 4 5
    sleep 1
    ffmpeg -v error -f x11grab -video_size 1280x720 -i "$DISPLAY" \
        -frames:v 1 -update 1 -y /out/settings-video.png
    xdotool mousemove 579 109 click 1
    sleep 1
    ffmpeg -v error -f x11grab -video_size 1280x720 -i "$DISPLAY" \
        -frames:v 1 -update 1 -y /out/settings-network.png
    xdotool mousemove 700 109 click 1
    xdotool mousemove 750 580 click --repeat 8 5
    sleep 1
    ffmpeg -v error -f x11grab -video_size 1280x720 -i "$DISPLAY" \
        -frames:v 1 -update 1 -y /out/settings-session.png
' > /out/startup.log 2>&1
result=$?
set -e
cat /out/startup.log
if [[ $result != 0 ]]; then
    echo "GUI exited unexpectedly: $result" >&2
    exit 1
fi
if grep -Ei 'failed to load component|is not installed|is not a type|ReferenceError|TypeError|Cannot load library|could not load.*plugin' /out/startup.log; then
    exit 1
fi
echo 'PASS: package installed, libraries resolved, GUI remained running for 20 seconds.'
