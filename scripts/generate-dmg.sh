#!/usr/bin/env bash
set -euo pipefail
# Requires Xcode command line tools and Qt 6.8.3 (qmake/macdeployqt on PATH).
source_root=$(cd "$(dirname "$0")/.." && pwd)
arch=${MAC_ARCH:-$(uname -m)}
case "$arch" in x86_64|arm64) ;; *) echo 'MAC_ARCH must be x86_64 or arm64' >&2; exit 1;; esac
version=${CI_VERSION:-$(tr -cd '0-9.' < "$source_root/app/version.txt")}
[[ "$version" =~ ^[A-Za-z0-9._-]+$ ]] || exit 1
build="$source_root/build/macos-$arch"
mkdir -p "$build" "$source_root/dist"
staging=$(mktemp -d "$build/dmg.XXXXXX")
# Only remove the directory returned by mktemp inside our build directory.
trap 'rm -rf "$staging"' EXIT
iconset="$build/moonlight.iconset"
mkdir -p "$iconset"
for size in 16 32 128 256 512; do
  sips -z "$size" "$size" "$source_root/app/deploy/linux/streamlight.png" --out "$iconset/icon_${size}x${size}.png" >/dev/null
  sips -z "$((size * 2))" "$((size * 2))" "$source_root/app/deploy/linux/streamlight.png" --out "$iconset/icon_${size}x${size}@2x.png" >/dev/null
done
iconutil -c icns "$iconset" -o "$build/moonlight.icns"
cd "$build"
qmake "$source_root/moonlight-qt.pro" CONFIG+=release CONFIG-=debug \
  "QMAKE_APPLE_DEVICE_ARCHS=$arch" QMAKE_MACOSX_DEPLOYMENT_TARGET=12.0 \
  "STREAMLIGHT_ICON=$build/moonlight.icns"
make -j"${BUILD_JOBS:-$(sysctl -n hw.logicalcpu)}" release
app="$staging/StreamLight.app"
ditto "$build/app/StreamLight.app" "$app"
macdeployqt "$app" "-qmldir=$source_root/app/gui" -appstore-compliant
# SDL3 is loaded dynamically by SDL2-compat; app.pro explicitly bundles it.
test -f "$app/Contents/Frameworks/libSDL3.dylib"
/usr/libexec/PlistBuddy -c 'Print CFBundleExecutable' "$app/Contents/Info.plist" | grep -qx StreamLight
lipo "$app/Contents/MacOS/StreamLight" -verify_arch "$arch"
# Ad-hoc signing permits local testing on Apple Silicon. This is not notarization.
codesign --force --deep --sign "${SIGNING_IDENTITY:--}" "$app"
codesign --verify --deep --strict "$app"
QT_QPA_PLATFORM=offscreen "$app/Contents/MacOS/StreamLight" --version
ln -s /Applications "$staging/Applications"
cp "$source_root/LICENSE" "$staging/LICENSE.txt"
output="$source_root/dist/StreamLight-$version-macos-$arch.dmg"
hdiutil create -ov -volname 'StreamLight' -srcfolder "$staging" -format UDZO "$output"
hdiutil verify "$output"
echo "Created $output"
