#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
version=$(tr -cd '0-9.' < "$root/app/version.txt")
revision=${PACKAGE_REVISION:-5}
[[ "$revision" =~ ^[0-9]+$ ]] || exit 1
appdir=$(cat "$root/build/current-appdir.txt")
test -x "$appdir/AppRun"
stage=$(mktemp -d "$root/build/deb.XXXXXX")
trap 'rm -rf "$stage"' EXIT
mkdir -p "$stage/opt/streamlight" "$stage/DEBIAN" "$stage/usr/bin" "$stage/usr/share/applications" "$stage/usr/share/pixmaps" "$stage/usr/share/doc/streamlight"
cp -a "$appdir/." "$stage/opt/streamlight/"
cat > "$stage/usr/bin/streamlight" <<'LAUNCHER'
#!/bin/sh
exec /opt/streamlight/AppRun "$@"
LAUNCHER
chmod 755 "$stage/usr/bin/streamlight"
cp "$root/app/deploy/linux/io.github.FoggyBytes.StreamLight.desktop" "$stage/usr/share/applications/"
cp "$root/app/deploy/linux/streamlight.png" "$stage/usr/share/pixmaps/"
cp "$root/LICENSE" "$stage/usr/share/doc/streamlight/copyright"
cat > "$stage/DEBIAN/control" <<CONTROL
Package: streamlight
Version: $version-$revision
Section: games
Priority: optional
Architecture: amd64
Maintainer: StreamLight fork contributors <noreply@github.com>
Depends: libc6 (>= 2.35), libstdc++6, libfontconfig1, libgl1, libegl1, libx11-6, libxcb1, libxkbcommon0, libasound2, libdbus-1-3
Recommends: libvulkan1, mesa-va-drivers
Homepage: https://github.com/rbaszak/StreamLight
Installed-Size: $(du -sk "$stage/opt" | cut -f1)
Description: Experimental StreamLight client with bundled Qt runtime
 Linux port developed using GPT Codex; not fully tested.
 Uses X11 or XWayland. The streaming host runs separately.
CONTROL
mkdir -p "$root/dist"
dpkg-deb --root-owner-group --build "$stage" "$root/dist/streamlight_${version}-${revision}_amd64.deb"
