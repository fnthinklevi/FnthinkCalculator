<#
.SYNOPSIS
  FnthinkCalculator release gate (PowerShell / Windows).

.DESCRIPTION
  PowerShell counterpart of tool/release.sh:
  version checks -> dart format -> flutter analyze -> flutter test
  -> signed pure arm64 build + purity check -> artifact archive.

  Build and purity verification are delegated to tool/build_release_arm64.ps1.

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File tool\release.ps1 -Preflight

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File tool\release.ps1
#>
param(
    [switch]$Preflight,
    [switch]$Help
)

$ErrorActionPreference = "Stop"
Set-Location "$PSScriptRoot/.."

function Show-Usage {
    Write-Host @"
用法: powershell -NoProfile -ExecutionPolicy Bypass -File tool\release.ps1 [-Preflight]

  -Preflight   只检查版本、设置页版本、签名配置、工作区与 tag 状态
  (无参数)     完整发版闸门：格式 -> analyze -> 全量测试 -> 签名纯 arm64 构建 -> 产物归档

脚本不会安装、提交、打 tag 或 push；这些步骤见 doc/release.md，均需人工确认。
"@
}

function Die([string]$Message) {
    Write-Host "ERROR: $Message" -ForegroundColor Red
    exit 1
}

function Say([string]$Message) {
    Write-Host "`n== $Message ==" -ForegroundColor Cyan
}

if ($Help) {
    Show-Usage
    exit 0
}

# --- version ---
$versionMatch = Select-String -Path "pubspec.yaml" -Pattern '^version:\s*(\S+)' | Select-Object -First 1
if (-not $versionMatch) {
    Die "pubspec.yaml 缺少 version 字段"
}
$versionLine = $versionMatch.Matches[0].Groups[1].Value
if ($versionLine -notmatch '^[0-9]+\.[0-9]+\.[0-9]{2}\+[0-9]+$') {
    Die "pubspec version 必须是 A.B.CC+BUILD（补丁位两位，如 0.2.01+5），当前: $(if ($versionLine) { $versionLine } else { '<空>' })"
}
$versionName = $versionLine.Split('+')[0]
$buildNumber = $versionLine.Split('+')[1]
$tag = "v${versionName}"

# --- signing + clean tree ---
if (-not (Test-Path "android/key.properties")) {
    Die "缺少 android/key.properties，无法生成真实签名包"
}
$dirty = (& git status --porcelain) -join "`n"
if ($dirty.Trim().Length -gt 0) {
    Die "工作区不干净；请先提交或清理变更：`n$dirty"
}

# --- settings page version must match pubspec ---
$settingsMatch = Select-String -Path "lib/features/settings/settings_page.dart" -Pattern "'([0-9]+\.[0-9]+\.[0-9]+)'" | Select-Object -First 1
$settingsVersion = if ($settingsMatch) { $settingsMatch.Matches[0].Groups[1].Value } else { "" }
if ($settingsVersion -ne $versionName) {
    Die "设置页版本 $(if ($settingsVersion) { $settingsVersion } else { '<空>' }) 与 pubspec ${versionName} 不一致"
}

# --- tag ---
& git rev-parse -q --verify "refs/tags/${tag}" > $null 2>&1
$tagExists = ($LASTEXITCODE -eq 0)

Say "版本 ${versionName}+${buildNumber}"

if ($Preflight) {
    if ($tagExists) {
        Write-Host "WARN: 本地已存在 tag ${tag}；同一版本号不应重复发版，请确认是否已提升版本。" -ForegroundColor Yellow
    }
    Say "Preflight OK"
    Write-Host "签名配置存在；工作区干净；设置页版本一致。"
    exit 0
}

if ($tagExists) {
    Die "tag ${tag} 已存在；请提升版本号，不要重复发版或覆盖 tag"
}

$testLog = [System.IO.Path]::GetTempFileName()
$buildLog = [System.IO.Path]::GetTempFileName()

try {
    Say "1/5 格式检查"
    & dart format --output=none --set-exit-if-changed lib test
    if ($LASTEXITCODE -ne 0) {
        Die "格式检查未通过；运行 dart format lib test 后重试"
    }

    Say "2/5 静态检查"
    & flutter analyze
    if ($LASTEXITCODE -ne 0) {
        Die "flutter analyze 未通过"
    }

    Say "3/5 全量测试"
    & flutter test 2>&1 | Tee-Object -FilePath $testLog
    if ($LASTEXITCODE -ne 0) {
        Die "flutter test 未通过"
    }
    $countMatch = [regex]::Matches((Get-Content -Raw $testLog), '\+([0-9]+)') | Select-Object -Last 1
    if (-not $countMatch) {
        Die "无法从测试输出解析用例数"
    }
    $testCount = $countMatch.Groups[1].Value

    Say "4/5 签名纯 arm64 构建"
    & "$PSScriptRoot/build_release_arm64.ps1" 2>&1 | Tee-Object -FilePath $buildLog
    if ($LASTEXITCODE -ne 0) {
        Die "签名构建或 APK 纯净检查未通过"
    }
    $shaMatch = [regex]::Match((Get-Content -Raw $buildLog), 'SHA-256:\s*([0-9A-Fa-f]{64})')
    if (-not $shaMatch.Success) {
        Die "无法从构建输出解析 SHA-256"
    }
    $sha = $shaMatch.Groups[1].Value.ToUpper()

    Say "5/5 归档产物"
    $artifactDir = "build/release"
    New-Item -ItemType Directory -Force -Path $artifactDir | Out-Null
    $artifact = Join-Path $artifactDir "FnthinkCalculator_${versionName}.apk"
    Copy-Item "build/app/outputs/flutter-apk/app-release.apk" $artifact -Force
    $artifactSha = (Get-FileHash $artifact -Algorithm SHA256).Hash
    if ($artifactSha -ne $sha) {
        Die "复制后的 APK SHA-256 与构建输出不一致"
    }
    [System.IO.File]::WriteAllText(
        "$artifact.sha256",
        "$sha  $(Split-Path $artifact -Leaf)`n"
    )
} finally {
    Remove-Item $testLog, $buildLog -ErrorAction SilentlyContinue
}

Write-Host "`n== 发版闸门通过 ==" -ForegroundColor Green
Write-Host "版本: ${versionName}+${buildNumber}"
Write-Host "测试: ${testCount} 例"
Write-Host "APK : ${artifact}"
Write-Host "SHA : ${sha}"
Write-Host "校验: ${artifact}.sha256"
Write-Host @"

接下来（见 doc/release.md，均需人工确认）：
1. 自动化冒烟: EMULATOR_SERIAL=emulator-<端口> bash tool/smoke_emulator.sh
2. 安装归档 APK 做手工冒烟: adb -s emulator-<端口> install -r "${artifact}"（全部 adb 命令带 -s）
3. 更新 doc/update.md、doc/base.md、README.md 的版本、SHA 与测试读数
4. 提交；获得授权后 push main，确认 CI 绿
5. 打 tag ${tag}；推送后确认 Release Check / Emulator Smoke 绿
6. GitHub Release 需明确授权
"@
