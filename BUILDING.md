# Building the experimental fork

Repository: https://github.com/rbaszak/StreamLight. Preserve the upstream history and license. Do not commit build output or credentials.

## Automated builds

`.github/workflows/release.yml` runs on main, codex branches, pull requests and manual dispatch. It builds:

- Arch/CachyOS package inside `packaging/arch/Dockerfile`, with menu tests and GUI smoke test.
- AppImage and `.deb` on Ubuntu 22.04 using Qt 6.8.3 and the dependency versions in `build-appimage.yml` (adapted from drainerlight).
- Separate macOS arm64 and x86_64 DMGs with Qt 6.8.3 and the vendored universal libraries.
- Windows x64 using MSVC 2022, Qt 6.8.3, vendored libraries and Inno Setup 6.

Fork Actions may initially need to be enabled in GitHub's Actions tab. Public standard GitHub-hosted runners can build the platforms concurrently; account settings and quotas still apply. No Mac, Apple developer account or Windows machine is required on the maintainer's desk for these CI builds. Apple notarization and Windows signing are not configured.

After reviewing successful branch builds, create and push a version tag, e.g. `v5.7.0-r5`. The release job waits for **all** build jobs, adds SHA256SUMS, and publishes a prerelease. Do not reuse an existing release tag. Increment `pkgrel` in `packaging/arch/PKGBUILD`, `PACKAGE_REVISION` default in `scripts/build-deb.sh`, and the default revision in the workflow together; update `app/version.txt` when the upstream application version changes. Tag naming affects DMG/AppImage/Windows filenames; native package versions come from app/version.txt plus their package revision.

Build outputs under `dist/` are ignored by Git. Artifacts remain available on successful individual jobs if another platform fails, but the release is not published until the whole matrix passes.

## Local macOS

Install Xcode command line tools and the Qt 6.8.3 macOS desktop SDK. Put its `bin` directory on PATH, then run from a clone:

```sh
bash scripts/generate-dmg.sh
# Optional architecture override, with the matching Qt libraries:
MAC_ARCH=arm64 bash scripts/generate-dmg.sh
```

The script generates the application icon, builds `StreamLight.app`, bundles Qt/QML and vendored libraries with macdeployqt, verifies the executable architecture and ad-hoc signature, checks `--version`, and creates a DMG with an Applications shortcut. Output: `dist/StreamLight-<version>-macos-<arch>.dmg`. This is a local-test distribution, not a notarized Apple release. `SIGNING_IDENTITY` can replace ad-hoc signing, but notarization requires a separately configured Apple account and workflow.

## Local Windows

Use an x64 Visual Studio 2022 developer shell with Qt 6.8.3 `msvc2022_64/bin` and Inno Setup 6 on PATH:

```powershell
./scripts/build-windows.ps1
```

The installer has a distinct ID and installation folder from the upstream installer. Settings still use StreamLight's existing profile. The ZIP likewise uses the normal profile unless `portable.dat` is created alongside the executable. Build in a clean checkout when dependencies change, to avoid stale DLLs in the staging directory.

## Local Linux

For native Arch/CachyOS follow LINUX.md or run `scripts/build-linux.ps1` with Docker Desktop on Windows. AppImage prerequisites and pinned dependency source versions are listed in `.github/workflows/build-appimage.yml`; after installing them:

```sh
APPIMAGE_EXTRACT_AND_RUN=1 bash scripts/build-appimage.sh
bash scripts/build-deb.sh
```

The Debian package repackages the same deployed runtime, rather than depending on older distribution Qt versions. It uses X11/XWayland. Test package installation, host pairing, hardware decoding, fullscreen, sound and controller input on a real target machine before recommending a release. The host's GPU drivers are not bundled.
