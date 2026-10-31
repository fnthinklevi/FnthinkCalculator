#!/bin/bash
set -euo pipefail

APK="${1:-build/app/outputs/flutter-apk/app-release.apk}"
SDK="${ANDROID_SDK_ROOT:-/d/fnthinklevi/Android/sdk}"
BUILD_TOOLS="$(find "$SDK/build-tools" -maxdepth 1 -type d | sort -V | tail -1)"

if [ ! -f "$APK" ]; then
  echo "APK not found: $APK" >&2
  exit 1
fi

entries="$(unzip -Z1 "$APK")"
failed=0

check_absent() {
  local label="$1"
  local pattern="$2"
  local hits
  hits="$(printf '%s\n' "$entries" | grep -E "$pattern" || true)"
  if [ -n "$hits" ]; then
    echo "FAIL: $label" >&2
    printf '%s\n' "$hits" | head -20 >&2
    failed=1
  else
    echo "OK: $label"
  fi
}

check_absent "no non-arm64 native libraries" '^lib/(x86|x86_64|armeabi|armeabi-v7a|mips|mips64)/'
check_absent "no bundled TTS audio/models" '(^|/)(voice/|.*\.wav$|.*\.onnx$|.*\.tflite$)'
check_absent "no signing material" '(^|/)(key\.properties|.*\.jks|.*\.keystore|.*\.p12|.*\.pem)(/|$)'
check_absent "no diagnostic entry" '(^|/)diag_main(\.dart)?(/|$)'
check_absent "no test assets" '(^|/)(test|integration_test)/'

libs="$(printf '%s\n' "$entries" | grep -E '^lib/.*\.so$' || true)"
bad_libs="$(printf '%s\n' "$libs" | grep -v '^lib/arm64-v8a/' || true)"
if [ -n "$bad_libs" ]; then
  echo "FAIL: mixed ABI .so files" >&2
  printf '%s\n' "$bad_libs" >&2
  failed=1
else
  echo "OK: only arm64-v8a .so files"
  printf '  %s\n' $libs
fi

if [ -f "$BUILD_TOOLS/apksigner.bat" ]; then
  certs="$("$BUILD_TOOLS/apksigner.bat" verify --print-certs "$APK" 2>&1)"
elif [ -x "$BUILD_TOOLS/apksigner" ]; then
  certs="$("$BUILD_TOOLS/apksigner" verify --print-certs "$APK" 2>&1)"
else
  echo "FAIL: apksigner not found in $BUILD_TOOLS" >&2
  certs=""
  failed=1
fi

if [ -n "$certs" ] && printf '%s\n' "$certs" | grep -q "CN=Android Debug"; then
  echo "FAIL: APK is debug-signed" >&2
  failed=1
elif [ -n "$certs" ]; then
  echo "OK: signed with non-debug certificate"
  printf '%s\n' "$certs" | grep -E 'Signer #1 certificate|DN:|SHA-256:' | sed 's/^/  /' || true
else
  failed=1
fi

echo "APK: $APK"
echo "Size: $(du -h "$APK" | cut -f1)"
echo "SHA-256: $(sha256sum "$APK" | cut -d' ' -f1)"

if [ "$failed" -ne 0 ]; then
  echo "PURITY CHECK FAILED" >&2
  exit 1
fi
echo "PURITY CHECK PASSED"
