[Setup]
AppId={{08320834-878B-43C8-AF86-DF9858ACAD02}
AppName=StreamLight (Experimental Fork)
AppVersion={#AppVersion}
AppPublisher=StreamLight fork contributors
AppPublisherURL=https://github.com/rbaszak/StreamLight
DefaultDirName={autopf}\StreamLight Fork
DefaultGroupName=StreamLight Fork
UninstallDisplayIcon={app}\StreamLight.exe
OutputDir={#OutputDir}
OutputBaseFilename=StreamLight-{#ReleaseVersion}-windows-x64-setup
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
SetupIconFile=..\..\app\streamlight.ico
LicenseFile=..\..\LICENSE
[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
[Icons]
Name: "{group}\StreamLight"; Filename: "{app}\StreamLight.exe"
[Run]
Filename: "{app}\StreamLight.exe"; Description: "Launch StreamLight"; Flags: nowait postinstall skipifsilent
