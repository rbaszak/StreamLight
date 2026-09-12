# 🎮 StreamLight

[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Linux%20%7C%20macOS-blue.svg)](#-packaging-and-downloads) [![Framework](https://img.shields.io/badge/Framework-Qt%206-brightgreen.svg)](https://www.qt.io/) [![Downloads](https://img.shields.io/github/downloads/rbaszak/StreamLight/total)](https://github.com/rbaszak/StreamLight/releases) [![Built on Moonlight](https://img.shields.io/badge/built%20on-Moonlight-blue?&logo=github)](https://github.com/moonlight-stream/moonlight-qt) [![Built with Claude Code](https://img.shields.io/badge/Built%20with-Claude%20Code-brightgreen.svg)](https://claude.ai/code) [![Built with GPT Codex](https://img.shields.io/badge/Built%20with-GPT%20Codex-brightgreen.svg)](https://openai.com/codex/)

<div align="center">
  <img width="960" height="540" alt="StreamLight home screen with game artwork" src="https://github.com/user-attachments/assets/6f2aca2f-8df6-4ff3-847f-a71cb450fbc8" />
</div>

**StreamLight** is a game-streaming client with a controller-friendly interface, built on [Moonlight-Qt](https://github.com/moonlight-stream/moonlight-qt). This unofficial fork of [FoggyBytes/StreamLight](https://github.com/FoggyBytes/StreamLight) adds **Linux and macOS builds**, convenient host startup and gentle menu sounds, while retaining Windows support.

Browse your hosts and game libraries from the sofa, customize streaming profiles, and connect to a Sunshine-compatible host. Optional integration with [**StreamTweak**](https://github.com/FoggyBytes/StreamTweak) adds host metrics, launch waiting and remote controls. **StreamTweak runs on the Windows host; the client can run on Linux, macOS or Windows.**

<div align="center">
  <img width="960" height="540" alt="StreamLight game library and game details" src="https://github.com/user-attachments/assets/554bb031-2b48-4696-951f-e9d1ed5b98b3" />
</div>

## ✨ New in this fork

- **Linux packages:** native CachyOS/Arch package, portable AppImage, and a DEB for Ubuntu/Mint with bundled Qt. Native Arch builds retain Wayland, X11 and DRM; portable builds use X11/XWayland.
- **macOS packages:** drag-to-Applications DMGs for Apple Silicon and Intel, with the app icon and bundled Qt/runtime libraries. Experimental, ad-hoc signed builds for macOS 12+.
- **Default host at startup:** open a host's **Options** and set it as the default. When it is online and paired, StreamLight opens its library automatically. If it is unavailable, you stay on the host screen; this does not launch a game or wake the host. Clear the choice in its options or **Settings → Session**.
- **Gentle menu sounds:** original navigation, confirmation and back sounds for mouse, keyboard and controller interaction. Enable/mute them and adjust their volume in **Settings → Session**. They stop while streaming and contain no recordings from Steam.
- **Cross-platform Releases:** one version tag builds CachyOS/Arch, AppImage, DEB, both macOS architectures and Windows installer/ZIP. Publication waits for the build and test jobs to pass.
- **Optional Steam artwork:** supplied images for the library cover, wide tile, background, logo and shortcut icon; see [Steam artwork](#-optional-steam-artwork).

**The Linux port and additional cross-platform work are being developed using GPT Codex. This fork is not fully tested.** The original StreamLight project credits Claude Code; both badges above preserve those contributions. Build success does not guarantee streaming, hardware decoding, HDR, sound or controller behavior on every machine. This fork is not endorsed by FoggyBytes or the Moonlight project.

## 📦 Packaging and downloads

The [Releases page](https://github.com/rbaszak/StreamLight/releases) is the destination for experimental builds. A `v*` tag starts all platform jobs; publication happens only if every job succeeds. Branch builds are downloadable from Actions and are not releases.

| System | Package | Notes |
| --- | --- | --- |
| CachyOS / Arch, x86-64 | `.pkg.tar.zst` | Native system dependencies; Wayland, X11 and DRM builds. Install/update with `sudo pacman -U ./streamlight-*.pkg.tar.zst`. Rolling distro updates can require a rebuild. |
| Linux, x86-64 | `.AppImage` | Bundled runtime; X11/XWayland. Make executable and launch. Built on Ubuntu 22.04; needs FUSE 2 or `--appimage-extract-and-run`. |
| Ubuntu / Mint, x86-64 | `.deb` | Native package management with runtime bundled under `/opt/streamlight`. Targets Ubuntu 22.04+ and Mint 21+; needs desktop X11/XWayland. Install/update with `sudo apt install ./streamlight_*_amd64.deb`. |
| macOS 12+, Apple Silicon | `macos-arm64.dmg` | Open DMG and drag StreamLight to Applications. Experimental, ad-hoc signed, not notarized. |
| macOS 12+, Intel | `macos-x86_64.dmg` | Same installation procedure; choose the architecture of your Mac. |
| Windows 10/11, x64 | `-setup.exe`, `.zip` | Experimental installer or unpacked application. Not Authenticode signed. |

Initial local testing covered the Arch package, GUI startup and menu behavior. The first CI builds passed on all platforms. macOS packages passed architecture, signature and `--version` checks; the Windows ZIP also passed a local `--version` check. Clean Ubuntu testing caught portable-package dependency omissions, now covered by the packaging smoke test. **Real streaming, GPU decoding and controller behavior still need manual testing on each target.** See [BUILDING.md](BUILDING.md) for build and release instructions and [LINUX.md](LINUX.md) for the Linux work and known limitations. Gatekeeper may require explicit approval in macOS System Settings → Privacy & Security for an unnotarized download; do not disable Gatekeeper globally.

## 🎨 Optional Steam artwork

The [steamgriddb](steamgriddb) folder contains optional PNG artwork you can assign to StreamLight after adding it to Steam as a non-Steam application. It only changes how the shortcut looks in your library/Big Picture; **none of these files is required to install or run StreamLight**, and they are not applied automatically.

| Image | Suggested use |
| --- | --- |
| [streamlight-cover.png](steamgriddb/streamlight-cover.png) | Vertical library cover |
| [streamlight-wide.png](steamgriddb/streamlight-wide.png) | Wide library tile |
| [streamlight-bgnd.png](steamgriddb/streamlight-bgnd.png) | Library page background / hero |
| [streamlight-logo.png](steamgriddb/streamlight-logo.png) | Logo over the library background |
| [streamlight-icon.png](steamgriddb/streamlight-icon.png) | Shortcut icon, where PNG icons are supported |

Download the original images you want and assign them using Steam's custom artwork options. You can keep Steam's default artwork instead. These files are included in this repository; no SteamGridDB account or extra integration is needed.

AppImage build infrastructure is adapted from [drainerlight/StreamLight](https://github.com/drainerlight/StreamLight), commit `1342d5d4c1dddfbcea27a885ea35ec2f6420a8f1`. Original project authors retain their credits and licenses. The following sections describe the inherited StreamLight features; platform-specific limitations still apply.

## ✅ Compatibility

Windows 10/11, plus experimental Linux and macOS builds listed above. Works as an ordinary Moonlight-compatible client against any **Sunshine / Apollo / Vibeshine / Vibepollo** host, and unlocks its paired feature set when [**StreamTweak**](https://github.com/FoggyBytes/StreamTweak) is running on the host.

> 🔐 **The bridge is authenticated.** Every command StreamLight sends is signed with its existing Moonlight identity certificate; the host approves each client once, via a 4-digit PIN shown on both screens. **Streaming never depends on it** — without approval you stream normally and simply lose the paired features. Each host card shows its state as a badge (AUTHORIZED / PENDING / DENIED).

> ⚠️ **Not affiliated with or endorsed by the Moonlight project.** StreamLight is an independent fork. For upstream Moonlight support, use the [official client](https://github.com/moonlight-stream/moonlight-qt).

## 🔥 Features

These features are inherited from upstream StreamLight. Fractional V-Sync, local link-speed matching, Hue Sync and automatic Tailscale launch are Windows-only client integrations; they are disabled or hidden on Linux and macOS. The fork installer does not seed Xbox app tile artwork.

**🕹️ Gamepad-first, keyboard-equal**
- Every action is reachable from the pad: D-pad across host tabs, library, settings tabs and dialogs, with a clickable prompt bar along the bottom
- **Prompts follow the device in your hands** — touch the keyboard and each glyph becomes the key to press; pick the pad back up and they return to that controller's own icons (Xbox / PlayStation / Nintendo, auto-detected or forced)
- **Rebindable shortcuts** — every in-stream keyboard hotkey and all three controller combos, in *Settings → Shortcuts*. Defaults are **LB + RB + A** quit, **+ X** performance overlay, **+ B** stream settings, chosen to stay clear of Steam's overlay

**🏠 Home and the host page**
- **Home** is your hosts as tabs under the wordmark, the selected one filling the screen: name, state, addresses, stream settings and actions at once. **LT / RT** move between hosts, **LB / RB** between that host's profiles
- **The host page** puts the library down the left at full height and the game in the spotlight beside it — cover, name, store, and the right verb (*Resume* if it is already running, *Play* if not)
- **Last played** *(5.7.0+)* — the game you last streamed on that host fills the right of its card, with the hours behind it and how long ago you left it. **Play again** starts it without opening the library, and the same game sits first on the host page under *Last played*
- **Play time** *(5.7.0+)* — how long you have streamed each game, beside the store on every row. Filed under the game's name, so it survives a reinstall, and resettable from the per-game panel
- **Per-host backgrounds** — a colour you pick or a picture of your own, with the card's gradient derived from it
- **Your accent colour** — five presets or any hex code. Status colours never follow it: online stays green, a pending link change amber, *Shutdown* red
- **Time, date and battery** in the top right of every screen, in the clock and date format you read

**🎬 In-stream**
- **Performance overlay, built line by line** — eleven lines to choose from, switched on and off *on the overlay itself* in Settings, plus corner, text colour, font size and transparency. Minimal / Default / Full remain as starting points
- **Stream Settings panel** — change resolution, frame rate, bitrate, HDR and frame pacing **while streaming**, applied with a brief reconnect and host-agnostic. It takes the corner the performance overlay is not using
- **Custom resolutions and frame rates** — any width and height, and any rate, not just the presets, from Settings or the in-stream panel
- **Your display's own values are offered too** *(5.5.0+)* — the resolution and refresh rate this machine reports appear in the pickers, so a 165 Hz or 16:10 screen needs nothing typed in. Marked with a dot in *Settings* and with the words *this display* in the in-stream panel, which offers the same list
- **Frame pacing** — Off or On, evening frames out with the same software pacer Moonlight uses
- **Fractional V-Sync** *(Windows/D3D11, 5.6.0+)* — shows each frame for a whole number of refreshes instead of once per refresh, so 60 FPS on a 120 Hz screen becomes one frame every two. Needs V-Sync and frame pacing, and a screen running at an exact multiple of the frame rate: at 60 FPS that is 120 / 180 / 240 Hz, and a 144 Hz screen wants 72 FPS. Off by default

**⚙️ Settings and profiles**
- Ten tabs, pill-style selectors instead of dropdowns, inline subtitles instead of tooltips, and a bitrate slider with hold-to-accelerate and a **Default** prompt
- **Per-host profiles** — up to three named profiles per host, each overriding resolution, frame rate, bitrate, HDR, codec, display mode, V-Sync, frame pacing, fractional V-Sync, audio, link matching, launch wait and Hue. Switchable from Home or the host page
- **Per-game overrides** on top of the active profile, for the settings that vary by title
- A setting that cannot act says so wherever you meet it — greyed, with the reason on the line beneath, in Settings, in the profile and in the per-game dialog alike
- Every change is written to disk the moment you make it

**🎯 Windows Xbox app integration**
- Branded tile artwork in the Windows 11 Xbox app's "My apps" section, provided by the upstream Windows installer; not configured by this fork's installer

**💡 Philips Hue Sync (Windows)**
- Optional: starts Hue Sync on this PC when a session begins and closes it when it ends, silently, with the install path resolved from the registry

## 🔗 Paired Features (with StreamTweak)

These cross the bridge and need both apps. The version shown is the **minimum StreamTweak** on the host.

All of them are switched on **per host**, in **Settings → StreamTweak** — a host added from StreamLight 5.2.0 on starts off, and hosts you were already using StreamTweak with are switched on for you on first run. Streaming itself is never affected either way.

- **Host link matching** *(Windows client, 8.1.0+)* — before each launch StreamLight measures the wired link that actually reaches that host, asks the host to come down to it, and starts the stream only once the host confirms. A host running faster than the client sends each frame as a burst the slower link cannot drain, and the packets that die first are the few carrying audio: the symptom is sound cutting out while the picture stays perfect. The client decides the speed because only the client knows its own connection; the host keeps the permission and the restore
- **Seamless launch** *(8.1.0+, opt-in)* — with **Wait for the game to appear** on, the stream window stays hidden until the host reports the game is really on screen, so you watch the game's cover art instead of the host's desktop rearranging itself. **B** or **Esc** reveals the host at any moment
- **Remote PIN unlock** *(8.1.0+)* — after a **Wake**, if the host comes up at its lock screen, a controller-navigable number pad takes its Windows PIN. The session carrying the PIN is never shown and never recorded on the host; wrong attempts stop at three, since Windows suspends the PIN after a few failures
- **Host metrics in the overlay** *(4.4.0+)* — GPU %, encoder %, GPU temperature, VRAM, CPU and network TX, hidden entirely when StreamTweak is unreachable
- **Store badges** *(5.0.0+)* — which store the selected game comes from, its mark beside its name on the host page: Steam, Epic, GOG, Ubisoft, Xbox, Battle.net and EA App
- **Session quality reporting** *(5.2.0+)* — FPS, drops, RTT, jitter, decode latency and bitrate sent every second; StreamTweak turns them into a grade and charts
- **Delivered vs target bitrate** *(8.0.0+)* — StreamLight reports the rate it was told to aim for, so the host can show what it actually delivered against it. Neither side can work that out alone
- **Remote host power-off** *(7.2.0+)* — a **Power…** chooser for the host, this PC, or both, on an authorized host only
- **Remote Windows Update** *(7.3.0+)* — scan, classify and install updates on the host, rebooting only if required, with a backgroundable progress view. Updates can also be installed before a shutdown
- **Remote session pause** *(6.0.0+)* — the Pause button on StreamTweak's dashboard ends the stream client-side
- **Tailscale in one tile** *(6.3.0+)* — a host reachable both on the LAN and over Tailscale stays a single tile that tracks both addresses and uses whichever is available, with an option to force the `100.x` endpoint. On Windows, pairs with the **Auto-start Tailscale** toggle. On Linux/macOS, start Tailscale separately using its normal system service/app

## ✨ What's New in 5.7.0 — Pick Up

StreamLight now remembers what you played and for how long, so the last game is one button away from the host list. Client-side, works with any host — including a plain Sunshine one.

- **Last played, on the host card.** A badge above the cover says how long you have put into that game and how long ago you left it; the artwork stands at the card's own height with its shadow, the title underneath. **Play again** sits below, on the same line as *Open*, *Profiles* and *Options* — **Right** from *Options* reaches it, or click it
- **Last played, at the top of the host page.** The same game as the first row, under its own heading, with the cursor already on it: open a host, press **A**, and you are back where you left off. Everything else follows under *All apps* in the order it always had
- **Play time per game.** How long you have streamed each one, beside the store on every row of the library, and hours plus session count in the spotlight. Kept per host, and filed under the game's *name* rather than the id the host hands out — so it survives uninstalling a game and installing it again. *Desktop* and *Steam Big Picture* never count
- **A *Reset stats* button** at the foot of the per-game panel, which clears that game's hours and session count for that host — greyed out when there is nothing to clear, because a total nobody can correct is a total that is eventually wrong
- **A game's title is never cut**, here or in the spotlight. It wraps to as many lines as it needs and shrinks to fit instead of ending in an ellipsis, so a name as long as *Metal Gear Solid 4: Guns of the Patriots – Master Collection Version* reads in full, last word included
- **The cover sizes itself to the title** on the host card: biggest when the name fits on one line, standing back when it takes three, so the block always ends on the same edge
- **Both screens present a game the same way** — cover, title, figures — because one component draws it on both, instead of two arrangements of the same idea drifting apart
- **The focus is a colour that crosses over**, not one that switches: fill, border and label warm into the accent together, so walking a row of buttons reads as one light travelling along it
- **The accent you pick now reaches everything.** The PIN pad that appears after waking a host was drawing its focus ring and its dots in the default cyan whatever you had chosen, because it named its own colours instead of reading yours
- **One type scale, one palette.** Text sizes come from a single scale instead of twenty-one hand-picked values a pixel or two apart, and *Settings* is drawn in the same colours as everywhere else — it carried its own flat greys while the rest of the app uses cooler ones, so it read a shade warmer than the screen it opens over
- **The chrome scales with the window.** The clock, the date, the battery and the button prompts along the bottom were fixed in place, which on a handheld made them the one part of the screen drawn smaller than everything around them
- **Settings tabs wrap.** **LB** and **RB** carry on past either end, so *About* is one press from *Video* instead of nine
- **Small grey text is readable.** Section headings, the captions under a game's figures and the muted half of a two-tone line all sat below the contrast the accessibility guidelines ask for. Disabled buttons look disabled now, too — they used to be drawn exactly like working ones
- **Two fixes worth naming.** Coming back from a stream puts the cursor back on the game you just closed — it moves to the top of the library the moment the session ends, so a cursor left where it was pointed at whatever had slid into that place. And the library's section headings now scroll with their rows: *Last played* used to stay pinned above the list, so after a few titles the screen claimed the game at the top of the view was the last one played
- ⚠️ **This replaces the host session report.** That panel described the *host's* last session — whatever had streamed, from whichever device — and needed an authorized StreamTweak to appear at all. This one describes what **you** played, from a record kept on this machine. The quality grade is not repeated here: StreamTweak's dashboard still calculates and shows it, and nothing was removed from the bridge

*Older releases are in [changelog.txt](changelog.txt).*

## 🏗️ Architecture

A Qt 6 / QML fork of Moonlight-Qt. The decoder pipeline — FFmpeg, D3D11VA, DXVA2, libplacebo — and the protocol, `moonlight-common-c`, are upstream's, and they track Moonlight's **development branch** rather than its releases: upstream has not tagged one since v6.1.0 in September 2024, while its master branch is still moving. As of 5.2.0 our copy of `moonlight-common-c` is identical to master's. The UI layer is ours.

Integration with StreamTweak runs over a TCP bridge on **port 47998** (LAN, line-delimited ASCII), carrying link speed (`NETINFO`, `SETSPEED`), host metrics (`STATS`), store data (`APPSTORES`), telemetry (`SESSIONDATA`), Tailscale presence, launch state (`GAMESTATE`), lock state, and the power and Windows Update commands. Each command is preceded by an `AUTH1` line signing it with the client's Moonlight certificate (RSA-SHA256); a one-time `ENROLL` registers the client with the host for approval.

```
StreamLight (Qt, client PC)
    │  TCP port 47998
    ▼
StreamTweak (WinUI 3, host PC)  →  Named Pipe  →  StreamTweakService (LocalSystem)
                                                           │
                                                           ▼
                                                NIC speed via CIM/WMI
                                                Host assets via filesystem
                                                Windows Update via WUA
```

## 📝 Installation

Download the package for your system from this fork's [Releases](https://github.com/rbaszak/StreamLight/releases). See [Packaging and downloads](#-packaging-and-downloads) above for each format and installation command. On macOS, open the DMG and drag StreamLight to Applications.

On Windows, settings — paired hosts, video / audio / input preferences, client certificate — live under `HKCU\Software\FoggyBytes\StreamLight`, and box art is cached in `%LOCALAPPDATA%\FoggyBytes\StreamLight`. Upgrades from 5.4.0 onward keep everything.

Up to 5.3.0 both lived under `Moonlight Game Streaming Project\Moonlight` — upstream Moonlight's own store, shared with it. 5.4.0 moved out of it and does not migrate anything, so the upgrade to 5.4.0 resets settings and pairing once. The old store is left untouched: an older StreamLight, or a Moonlight installation, still finds its data there.

## 🙏 Support the original project
[![Donate with PayPal](https://img.shields.io/badge/Donate-PayPal-blue.svg)](https://paypal.me/foggypunk)

## 🤝 Acknowledgements

- [**StreamTweak**](https://github.com/FoggyBytes/StreamTweak) — the host-side companion, designed in lockstep with StreamLight
- [**Moonlight**](https://github.com/moonlight-stream/moonlight-qt) — the open-source client this fork is built on; full credit to its contributors
- [**Sunshine**](https://github.com/LizardByte/Sunshine) — the streaming host that started it all
- [**Apollo**](https://github.com/ClassicOldSong/Apollo) — community-driven Sunshine fork
- [**Vibeshine**](https://github.com/Nonary/vibeshine) and [**Vibepollo**](https://github.com/Nonary/Vibepollo) — fully supported

## License
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-green.svg)](https://www.gnu.org/licenses/gpl-3.0)

StreamLight is released under the GPL v3 License, in accordance with the upstream Moonlight license.
