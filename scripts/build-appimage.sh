#!/usr/bin/env bash
set -euo pipefail
source_root=$(cd "$(dirname "$0")/.." && pwd)
version=${CI_VERSION:-$(tr -cd '0-9.' < "$source_root/app/version.txt")}
[[ "$version" =~ ^[A-Za-z0-9._-]+$ ]] || exit 1
build="$source_root/build/build-release"
mkdir -p "$source_root/build"
# Fresh staging avoids stale dependencies surviving subsequent builds.
deploy=$(mktemp -d "$source_root/build/appdir.XXXXXX")
output="$source_root/dist"
mkdir -p "$build" "$output"
cd "$build"
# Portable builds use X11/XWayland, avoiding bundled Wayland libraries that can
# conflict with newer host Mesa. Native Arch packages retain Wayland and DRM.
qmake6 "$source_root/moonlight-qt.pro" CONFIG+=release CONFIG+=disable-wayland \
  CONFIG+=disable-libdrm "PREFIX=$deploy/usr" DEFINES+=APP_IMAGE
make -j"${BUILD_JOBS:-$(nproc)}" release
make install
extra=()
sdl2=$(ldd "$deploy/usr/bin/streamlight" | awk '/libSDL2(-2[.]0)?[.]so[^ ]* =>/ {print $3; exit}')
sdl3=$(ldconfig -p | awk '/libSDL3.so.0 / {path=$NF} END {print path}')
# SDL2-compat loads SDL3 dynamically. Do not mistake SDL2_ttf for SDL2,
# or rely on ldd to discover this dependency for linuxdeployqt.
if [ -n "$sdl3" ]; then
  test -f "$sdl3"
  mkdir -p "$deploy/usr/lib"
  cp -L "$sdl3" "$deploy/usr/lib/libSDL3.so.0"
  extra+=("-executable=$deploy/usr/lib/libSDL3.so.0")
elif [ -n "$sdl2" ] && grep -aq 'libSDL3.so.0' "$sdl2"; then
  echo 'SDL2-compat requires SDL3, but libSDL3.so.0 was not found' >&2
  exit 1
fi
cd "$output"
export VERSION="$version" ARCH=x86_64
linuxdeployqt "$deploy/usr/share/applications/io.github.FoggyBytes.StreamLight.desktop" \
  -qmake=qmake6 "-qmldir=$source_root/app/gui" -appimage -extra-plugins=tls "${extra[@]}"
# Keep the deployed AppDir for the native Debian package using identical libraries.
printf '%s\n' "$deploy" > "$source_root/build/current-appdir.txt"
test -f "$output/StreamLight-$version-x86_64.AppImage"
