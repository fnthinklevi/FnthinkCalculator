#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."

SERIAL="${EMULATOR_SERIAL:-emulator-5554}"
if ! adb devices | awk -v target="$SERIAL" '$1 == target && $2 == "device" { found = 1 } END { exit !found }'; then
  echo "ERROR: 未找到在线的模拟器 $SERIAL" >&2
  echo "请先启动 AVD，并设置 EMULATOR_SERIAL（例如 emulator-5554）。" >&2
  exit 1
fi

echo "== 模拟器自动化冒烟: $SERIAL =="
flutter test integration_test/app_smoke_test.dart -d "$SERIAL"
echo "== 模拟器自动化冒烟通过 =="
