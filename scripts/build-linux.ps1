param([int]$Jobs = 4)
$ErrorActionPreference = 'Stop'
if ($Jobs -lt 1) { throw 'Jobs must be positive' }
$sourceRoot = Split-Path -Parent $PSScriptRoot
$outputRoot = Join-Path $sourceRoot 'dist'
New-Item -ItemType Directory -Force $outputRoot | Out-Null
docker build -t streamlight-linux-builder -f (Join-Path $sourceRoot 'packaging/arch/Dockerfile') $sourceRoot
if ($LASTEXITCODE -ne 0) { throw 'Docker image build failed' }
docker run --rm --env "BUILD_JOBS=$Jobs" `
    --mount "type=bind,source=$sourceRoot,target=/src,readonly" `
    --mount "type=bind,source=$outputRoot,target=/out" streamlight-linux-builder
if ($LASTEXITCODE -ne 0) { throw 'Linux build failed' }
docker run --rm --user root `
    --mount "type=bind,source=$sourceRoot,target=/src,readonly" `
    --mount "type=bind,source=$outputRoot,target=/out" `
    streamlight-linux-builder bash /src/packaging/arch/smoke-test.sh
if ($LASTEXITCODE -ne 0) { throw 'Package startup test failed; see dist/startup.log' }
Write-Host "Package saved to $outputRoot"
