#!/bin/bash
# Force-sync plugin registrants từ pubspec.yaml.
#
# Vấn đề: Flutter 3.29.3 đôi khi không regenerate
#   - ios/Runner/GeneratedPluginRegistrant.h/.m
#   - ios/Flutter/Generated.xcconfig
#   - android/.../GeneratedPluginRegistrant.java
#   - .flutter-plugins-dependencies
# khi chạy `flutter pub get` lẻ (nhất là khi pod thiếu hoặc cache lệch).
#
# Script này force regen bằng cách:
#   1. Xoá toàn bộ file auto-gen cũ → ép tool tạo lại từ đầu.
#   2. Chạy `flutter pub get`.
#   3. Chạy `flutter build ios --config-only --no-pub` để ép iOS regen
#      (kể cả khi pub get bỏ qua iOS branch).
#   4. Nếu pod có sẵn → `pod install` để link .xcconfig với pods mới.
#
# Cách dùng:
#   bash scripts/sync_flutter_plugins.sh
#
# Gọi mỗi khi:
#   - Thêm/xoá dependencies trong pubspec.yaml
#   - Sau khi pull code có thay đổi pubspec
#   - Khi build fail vì plugin registrant mismatch

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

# Cho phép set FLUTTER_CMD=fvm khi dùng FVM (mặc định: flutter trong PATH)
FLUTTER_CMD=${FLUTTER_CMD:-flutter}
if command -v fvm >/dev/null 2>&1 && [ -f .fvmrc ]; then
  FLUTTER_CMD="fvm flutter"
fi

echo "🧹 Removing stale generated plugin registrants..."
rm -f ios/Runner/GeneratedPluginRegistrant.h
rm -f ios/Runner/GeneratedPluginRegistrant.m
rm -f ios/Flutter/Generated.xcconfig
rm -f ios/Flutter/flutter_export_environment.sh
rm -f android/app/src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java
rm -f .flutter-plugins
rm -f .flutter-plugins-dependencies

echo "📦 Running pub get..."
$FLUTTER_CMD pub get

echo "🔧 Syncing iOS Generated.xcconfig from pubspec.yaml..."
bash scripts/sync_ios_generated_xcconfig.sh

# Verify GeneratedPluginRegistrant đã được regen
if [ ! -f ios/Runner/GeneratedPluginRegistrant.m ]; then
  echo "⚠️  pub get không tạo lại ios/Runner/GeneratedPluginRegistrant.m"
  echo "    Thử force regen qua flutter build ios --config-only..."
  $FLUTTER_CMD build ios --config-only --no-pub 2>&1 | grep -v "^$" | tail -5 || true
fi

if [ ! -f ios/Runner/GeneratedPluginRegistrant.m ]; then
  echo "❌ Không tạo được GeneratedPluginRegistrant.m. Kiểm tra:"
  echo "   - CocoaPods đã cài? (pod --version)"
  echo "   - Có dùng đúng fvm flutter? (which flutter)"
  echo "   - pubspec.yaml có khối flutter.module: ? (xoá nếu có)"
  exit 1
fi

# pod install nếu pod có
if command -v pod >/dev/null 2>&1; then
  echo "🍫 Running pod install..."
  (cd ios && pod install --silent) || echo "⚠️  pod install gặp lỗi — bỏ qua, kiểm tra Podfile sau."
else
  echo "⚠️  CocoaPods không có. Cài: brew install cocoapods"
fi

echo ""
echo "✅ Plugin registrants synced successfully:"
echo "   - ios/Runner/GeneratedPluginRegistrant.h/.m"
echo "   - ios/Flutter/Generated.xcconfig"
echo "   - android/app/src/main/java/.../GeneratedPluginRegistrant.java"
echo "   - .flutter-plugins-dependencies"
