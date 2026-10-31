#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [ ! -f android/key.properties ]; then
  echo "android/key.properties is missing; configure release signing first." >&2
  exit 1
fi

flutter build apk --release --target-platform android-arm64
tool/check_apk_purity.sh build/app/outputs/flutter-apk/app-release.apk
