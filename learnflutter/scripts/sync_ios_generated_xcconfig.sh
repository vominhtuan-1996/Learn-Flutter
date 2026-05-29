#!/bin/bash
# Generate ios/Flutter/Generated.xcconfig + flutter_export_environment.sh
# từ pubspec.yaml + .fvmrc. Dùng khi `flutter pub get` không tự sync
# (bug Flutter 3.29.3: file chỉ được viết khi build native, mà build lại
# yêu cầu file tồn tại sẵn → vòng luẩn quẩn).
set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

# version: x.y.z+build
VERSION_LINE=$(grep -E "^version:" pubspec.yaml | head -1 | awk '{print $2}')
BUILD_NAME=${VERSION_LINE%%+*}
BUILD_NUMBER=${VERSION_LINE##*+}
[ "$BUILD_NAME" = "$BUILD_NUMBER" ] && BUILD_NUMBER=1

# Flutter SDK path (ưu tiên fvm)
if [ -L .fvm/flutter_sdk ]; then
  FLUTTER_ROOT=$(readlink .fvm/flutter_sdk)
elif command -v fvm >/dev/null 2>&1 && [ -f .fvmrc ]; then
  FLUTTER_VERSION=$(grep -o '"flutter": "[^"]*' .fvmrc | cut -d'"' -f4)
  FLUTTER_ROOT="$HOME/fvm/versions/$FLUTTER_VERSION"
else
  FLUTTER_ROOT=$(dirname $(dirname $(which flutter)))
fi

XCCONFIG=ios/Flutter/Generated.xcconfig
ENV_SH=ios/Flutter/flutter_export_environment.sh

mkdir -p ios/Flutter

cat > "$XCCONFIG" <<EOF
// This is a generated file; do not edit or check into version control.
FLUTTER_ROOT=$FLUTTER_ROOT
FLUTTER_APPLICATION_PATH=$PROJECT_ROOT
COCOAPODS_PARALLEL_CODE_SIGN=true
FLUTTER_TARGET=lib/main.dart
FLUTTER_BUILD_DIR=build
FLUTTER_BUILD_NAME=$BUILD_NAME
FLUTTER_BUILD_NUMBER=$BUILD_NUMBER
EXCLUDED_ARCHS[sdk=iphonesimulator*]=i386 arm64
EXCLUDED_ARCHS[sdk=iphoneos*]=armv7
DART_OBFUSCATION=false
TRACK_WIDGET_CREATION=true
TREE_SHAKE_ICONS=false
PACKAGE_CONFIG=.dart_tool/package_config.json
EOF

cat > "$ENV_SH" <<EOF
#!/bin/sh
# This is a generated file; do not edit or check into version control.
export "FLUTTER_ROOT=$FLUTTER_ROOT"
export "FLUTTER_APPLICATION_PATH=$PROJECT_ROOT"
export "COCOAPODS_PARALLEL_CODE_SIGN=true"
export "FLUTTER_TARGET=lib/main.dart"
export "FLUTTER_BUILD_DIR=build"
export "FLUTTER_BUILD_NAME=$BUILD_NAME"
export "FLUTTER_BUILD_NUMBER=$BUILD_NUMBER"
export "DART_OBFUSCATION=false"
export "TRACK_WIDGET_CREATION=true"
export "TREE_SHAKE_ICONS=false"
export "PACKAGE_CONFIG=.dart_tool/package_config.json"
EOF
chmod +x "$ENV_SH"

echo "✅ Synced $XCCONFIG"
echo "   FLUTTER_BUILD_NAME=$BUILD_NAME"
echo "   FLUTTER_BUILD_NUMBER=$BUILD_NUMBER"
echo "   FLUTTER_ROOT=$FLUTTER_ROOT"
