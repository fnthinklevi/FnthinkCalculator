#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."

usage() {
  cat <<'EOF'
用法: bash tool/release.sh [--preflight]

  --preflight  只检查版本、设置页版本、签名配置、工作区与 tag 状态
  (无参数)     完整发版闸门：格式 → analyze → 全量测试 → 签名纯 arm64 构建 → 产物归档

脚本不会安装、提交、打 tag 或 push；这些步骤见 doc/release.md，均需人工确认。
EOF
}

MODE="${1:-}"
if [ "$MODE" = "--help" ] || [ "$MODE" = "-h" ]; then
  usage
  exit 0
fi
if [ -n "$MODE" ] && [ "$MODE" != "--preflight" ]; then
  echo "未知参数: $MODE" >&2
  usage
  exit 2
fi

die() {
  echo "ERROR: $*" >&2
  exit 1
}
say() {
  printf '\n== %s ==\n' "$*"
}

VERSION_LINE="$(awk '/^version:/{print $2; exit}' pubspec.yaml)"
if [[ ! "$VERSION_LINE" =~ ^[0-9]+\.[0-9]+\.[0-9]+\+[0-9]+$ ]]; then
  die "pubspec version 必须是 X.Y.Z+N，当前: ${VERSION_LINE:-<空>}"
fi
VERSION_NAME="${VERSION_LINE%%+*}"
BUILD_NUMBER="${VERSION_LINE##*+}"
TAG="v${VERSION_NAME}"

if [ ! -f android/key.properties ]; then
  die "缺少 android/key.properties，无法生成真实签名包"
fi
if [ -n "$(git status --porcelain)" ]; then
  die "工作区不干净；请先提交或清理变更：
$(git status --short)"
fi

SETTINGS_VERSION="$(grep -oE "'[0-9]+\.[0-9]+\.[0-9]+'" lib/features/settings/settings_page.dart | head -1 | tr -d "'")"
if [ "$SETTINGS_VERSION" != "$VERSION_NAME" ]; then
  die "设置页版本 ${SETTINGS_VERSION:-<空>} 与 pubspec ${VERSION_NAME} 不一致"
fi

TAG_EXISTS=false
if git rev-parse -q --verify "refs/tags/${TAG}" >/dev/null; then
  TAG_EXISTS=true
fi

say "版本 ${VERSION_NAME}+${BUILD_NUMBER}"

if [ "$MODE" = "--preflight" ]; then
  if [ "$TAG_EXISTS" = true ]; then
    echo "WARN: 本地已存在 tag ${TAG}；同一版本号不应重复发版，请确认是否已提升版本。" >&2
  fi
  say "Preflight OK"
  echo "签名配置存在；工作区干净；设置页版本一致。"
  exit 0
fi

if [ "$TAG_EXISTS" = true ]; then
  die "tag ${TAG} 已存在；请提升版本号，不要重复发版或覆盖 tag"
fi

TEST_LOG="$(mktemp)"
BUILD_LOG="$(mktemp)"
trap 'rm -f "$TEST_LOG" "$BUILD_LOG"' EXIT

say "1/5 格式检查"
dart format --output=none --set-exit-if-changed lib test

say "2/5 静态检查"
flutter analyze

say "3/5 全量测试"
flutter test 2>&1 | tee "$TEST_LOG"
TEST_COUNT="$(grep -oE '\+[0-9]+' "$TEST_LOG" | tail -1 | tr -d '+')"
if [ -z "$TEST_COUNT" ]; then
  die "无法从测试输出解析用例数"
fi

say "4/5 签名纯 arm64 构建"
bash tool/build_release_arm64.sh 2>&1 | tee "$BUILD_LOG"

SHA="$(sed -n 's/^SHA-256: //p' "$BUILD_LOG" | tail -1)"
if [ -z "$SHA" ]; then
  die "无法从构建输出解析 SHA-256"
fi

say "5/5 归档产物"
ARTIFACT_DIR="build/release"
mkdir -p "$ARTIFACT_DIR"
ARTIFACT="$ARTIFACT_DIR/FnthinkCalculator_${VERSION_NAME}.apk"
cp build/app/outputs/flutter-apk/app-release.apk "$ARTIFACT"
ARTIFACT_SHA="$(sha256sum "$ARTIFACT" | awk '{print $1}')"
if [ "$ARTIFACT_SHA" != "$SHA" ]; then
  die "复制后的 APK SHA-256 与构建输出不一致"
fi
printf '%s  %s\n' "$SHA" "$(basename "$ARTIFACT")" > "${ARTIFACT}.sha256"

cat <<EOF

== 发版闸门通过 ==
版本: ${VERSION_NAME}+${BUILD_NUMBER}
测试: ${TEST_COUNT} 例
APK : ${ARTIFACT}
SHA : ${SHA}
校验: ${ARTIFACT}.sha256

接下来（见 doc/release.md，均需人工确认）：
1. 模拟器冒烟: 启动 AVD 后 adb -s emulator-<端口> install -r "${ARTIFACT}"（全部 adb 命令带 -s）
2. 更新 doc/update.md、doc/base.md、README.md 的版本、SHA 与测试读数
3. 提交文档与版本变更
4. 冒烟通过后打 tag ${TAG}；push 与 GitHub Release 需明确授权
EOF
