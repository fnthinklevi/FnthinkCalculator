<#
.SYNOPSIS
    Build a pure arm64-v8a signed release APK for FnthinkCalculator.
.DESCRIPTION
    Checks android/key.properties, runs flutter build with arm64Only, then
    performs the same purity gates as check_apk_purity.sh on the produced APK:
      - only arm64-v8a native libraries
      - no signing material, models, raw audio, test or diagnostic assets
      - apksigner present and APK signed with non-debug certificate
    Exits non-zero on any failure so CI or callers can abort.
#>
param(
    [string]$ApkPath = "build/app/outputs/flutter-apk/app-release.apk"
)

$ErrorActionPreference = "Stop"
Set-Location "$PSScriptRoot/.."

function Fail([string]$Message) {
    Write-Host "FAIL: $Message" -ForegroundColor Red
    $script:failed = $true
}
function Ok([string]$Message) { Write-Host "OK: $Message" -ForegroundColor Green }
function CheckAbsent([string]$Label, [string[]]$Patterns) {
    $hits = @()
    foreach ($p in $Patterns) {
        $hits += $script:entries | Where-Object { $_ -match $p }
    }
    $hits = $hits | Select-Object -Unique
    if ($hits.Count -gt 0) {
        Fail $Label
        $hits | Select-Object -First 20 | ForEach-Object { Write-Host "  $_" -ForegroundColor DarkRed }
    } else {
        Ok $Label
    }
}

if (-not (Test-Path "android/key.properties")) {
    Write-Host "android/key.properties is missing; configure release signing first." -ForegroundColor Red
    exit 1
}

Write-Host "==> flutter build apk --release --target-platform android-arm64 --android-project-arg arm64Only=true"
& flutter build apk --release --target-platform android-arm64 --android-project-arg arm64Only=true
if ($LASTEXITCODE -ne 0) {
    Write-Host "flutter build failed (exit $LASTEXITCODE)" -ForegroundColor Red
    exit $LASTEXITCODE
}

if (-not (Test-Path $ApkPath)) {
    Write-Host "APK not found: $ApkPath" -ForegroundColor Red
    exit 1
}

# --- resolve SDK and latest build-tools ---
$sdkRoot = $env:ANDROID_SDK_ROOT
if (-not $sdkRoot -or -not (Test-Path $sdkRoot)) {
    if (Test-Path "android/local.properties") {
        $line = Get-Content "android/local.properties" | Where-Object { $_ -match '^\s*sdk\.dir\s*=\s*(.+)$' } | Select-Object -First 1
        if ($line) { $sdkRoot = $Matches[1] -replace '\\','/' }
    }
}
if (-not $sdkRoot -or -not (Test-Path $sdkRoot)) {
    Write-Host "Cannot locate Android SDK (ANDROID_SDK_ROOT or android/local.properties)." -ForegroundColor Red
    exit 1
}
$buildTools = Get-ChildItem "$sdkRoot/build-tools" -Directory |
    Sort-Object { [version]$_.Name } -Descending |
    Select-Object -First 1
$apksigner = Join-Path $buildTools.FullName "apksigner.bat"
if (-not (Test-Path $apksigner)) { $apksigner = Join-Path $buildTools.FullName "apksigner" }

# --- enumerate APK entries ---
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::OpenRead((Resolve-Path $ApkPath))
$script:entries = $zip.Entries | ForEach-Object { $_.FullName }
$script:failed = $false

try {
    Write-Host ""
    Write-Host "==> APK purity check"

    CheckAbsent "no non-arm64 native libraries" @('^lib/(x86|x86_64|armeabi|armeabi-v7a|mips|mips64)/')
    CheckAbsent "no bundled TTS models or raw audio" @('(?i)(\.onnx$|\.tflite$|\.wav$)')
    CheckAbsent "no signing material" @('(?i)(key\.properties|\.jks$|\.keystore$|\.p12$|\.pem$)')
    CheckAbsent "no diagnostic entry" @('(?i)/diag_main(\.dart)?$')
    CheckAbsent "no test assets" @('^(test|integration_test)/|/(test|integration_test)/')

    $allSo = $script:entries | Where-Object { $_ -match '^lib/.*\.so$' }
    $badSo = $allSo | Where-Object { $_ -notmatch '^lib/arm64-v8a/' }
    if ($badSo.Count -gt 0) {
        Fail "mixed ABI .so files"
        $badSo | ForEach-Object { Write-Host "  $_" -ForegroundColor DarkRed }
    } else {
        Ok "only arm64-v8a .so files ($($allSo.Count) total)"
    }

    if (-not (Test-Path $apksigner)) {
        Fail "apksigner not found under $($buildTools.FullName)"
    } else {
        $certs = & $apksigner verify --print-certs $ApkPath 2>&1 | Out-String
        if ($LASTEXITCODE -ne 0) {
            Fail "apksigner verify failed: $certs"
        } elseif ($certs -match 'CN=Android Debug') {
            Fail "APK is debug-signed"
        } else {
            Ok "signed with non-debug certificate"
            ($certs -split "`n") | Where-Object { $_ -match 'Signer|DN:|SHA-256:' } |
                ForEach-Object { Write-Host "  $_" }
        }
    }
} finally {
    $zip.Dispose()
}

$apkItem = Get-Item $ApkPath
$hash = (Get-FileHash $ApkPath -Algorithm SHA256).Hash
Write-Host ""
Write-Host "APK: $((Resolve-Path $ApkPath).Path)"
Write-Host ("Size: {0:N2} MB" -f ($apkItem.Length / 1MB))
Write-Host "SHA-256: $hash"

if ($script:failed) {
    Write-Host "`nPURITY CHECK FAILED" -ForegroundColor Red
    exit 1
}
Write-Host "`nPURITY CHECK PASSED" -ForegroundColor Green
