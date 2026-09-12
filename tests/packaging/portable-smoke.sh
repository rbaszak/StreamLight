#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
assets=${PACKAGE_DIR:-/out}
apt-get update -qq
apt-get install -y --no-install-recommends "$assets"/*.deb xvfb xauth
export QT_QPA_PLATFORM=xcb SDL_VIDEODRIVER=x11 SDL_AUDIODRIVER=dummy
xvfb-run -a streamlight --version
set +e
xvfb-run -a timeout --kill-after=5 15 streamlight > /tmp/deb-gui.log 2>&1
status=$?
set -e
cat /tmp/deb-gui.log
[ "$status" = 124 ]
! grep -E 'QQmlApplicationEngine failed|is not installed|Type .* unavailable|ReferenceError|error while loading shared libraries' /tmp/deb-gui.log
cp "$assets"/*.AppImage /tmp/StreamLight.AppImage
chmod +x /tmp/StreamLight.AppImage
export APPIMAGE_EXTRACT_AND_RUN=1
xvfb-run -a /tmp/StreamLight.AppImage --version
set +e
xvfb-run -a timeout --kill-after=5 15 /tmp/StreamLight.AppImage > /tmp/appimage-gui.log 2>&1
status=$?
set -e
cat /tmp/appimage-gui.log
[ "$status" = 124 ]
! grep -E 'QQmlApplicationEngine failed|is not installed|Type .* unavailable|ReferenceError|error while loading shared libraries' /tmp/appimage-gui.log
apt-get remove -y streamlight
test ! -e /opt/streamlight/AppRun
echo 'PASS: DEB install, GUI, uninstall; AppImage version and GUI'
