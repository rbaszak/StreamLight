#!/usr/bin/env bash
set -euo pipefail
cd /build
cp /src/packaging/arch/PKGBUILD ./PKGBUILD
version=$(LC_ALL=C tr -cd '0-9.' < /src/app/version.txt)
sed -i "s/^pkgver=.*/pkgver=$version/" PKGBUILD
makepkg --force --noconfirm
package=$(makepkg --packagelist)
cp "$package" /out/
basename "$package" > /out/current-package.txt
pacman -Q > /out/build-dependencies.txt
cd /out
sha256sum "$(cat current-package.txt)" > SHA256SUMS
