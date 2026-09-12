param([string]$Version = $env:CI_VERSION)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
if (!$Version) { $Version = (Get-Content "$root/app/version.txt" -Raw).Trim() }
if ($Version -notmatch '^[A-Za-z0-9._-]+$') { throw 'Invalid release version' }
$appVersion = (Get-Content "$root/app/version.txt" -Raw).Trim()
$build = Join-Path $root 'build/windows-x64'
$deploy = Join-Path $root 'build/windows-deploy'
$out = Join-Path $root 'dist'
New-Item -ItemType Directory -Force $build,$deploy,$out | Out-Null
function Run([string]$Program, [string[]]$Arguments) {
    & $Program @Arguments
    if ($LASTEXITCODE -ne 0) { throw "$Program failed: $LASTEXITCODE" }
}
Push-Location $build
try {
    Run 'qmake' @("$root/moonlight-qt.pro", 'CONFIG+=release', 'CONFIG-=debug')
    Run "$root/scripts/jom.exe" @('release')
} finally { Pop-Location }
Copy-Item "$build/app/release/StreamLight.exe" $deploy
Copy-Item "$build/AntiHooking/release/AntiHooking.dll" $deploy
Copy-Item "$root/libs/windows/lib/x64/*.dll" $deploy
Copy-Item "$root/app/SDL_GameControllerDB/gamecontrollerdb.txt" $deploy
Copy-Item "$root/LICENSE" "$deploy/LICENSE.txt"
Run 'windeployqt' @('--release', '--qmldir', "$root/app/gui", '--no-translations', '--no-compiler-runtime', '--no-ffmpeg', '--no-system-dxc-compiler', "$deploy/StreamLight.exe")
$vswhere = "${env:ProgramFiles(x86)}/Microsoft Visual Studio/Installer/vswhere.exe"
$crt = & $vswhere -latest -find 'VC/Redist/MSVC/*/x64/Microsoft.VC*.CRT'
$crt = $crt | Select-Object -Last 1
if (!$crt) { throw 'MSVC redistributable DLL directory not found' }
Copy-Item "$crt/*.dll" $deploy
Run 'iscc' @("/DAppVersion=$appVersion", "/DReleaseVersion=$Version", "/DSourceDir=$deploy", "/DOutputDir=$out", "$root/packaging/windows/StreamLight.iss")
# ZIP uses the normal profile, like the installer, unless portable.dat is created.
Compress-Archive -Path "$deploy/*" -DestinationPath "$out/StreamLight-$Version-windows-x64.zip" -Force
