#!/bin/bash

echo "🚀 iOS / Flutter Disk Cleaner PRO"
echo "----------------------------------"

# Danh sách folder phổ biến
paths=(
  # Xcode / iOS
  "$HOME/Library/Developer/Xcode/DerivedData"
  "$HOME/Library/Developer/Xcode/Archives"
  "$HOME/Library/Developer/Xcode/iOS DeviceSupport"
  "$HOME/Library/Developer/Xcode/watchOS DeviceSupport"
  "$HOME/Library/Developer/Xcode/tvOS DeviceSupport"
  "$HOME/Library/Developer/Xcode/UserData/IB Support"
  "$HOME/Library/Developer/Xcode/UserData/Previews"
  "$HOME/Library/Developer/CoreSimulator/Caches"
  "$HOME/Library/Developer/CoreSimulator/Devices"
  "$HOME/Library/Caches/com.apple.dt.Xcode"

  # CocoaPods
  "$HOME/Library/Caches/CocoaPods"
  "$HOME/.cocoapods/repos"

  # System caches
  "$HOME/Library/Caches"
  "$HOME/Library/Logs"
  "$HOME/Library/Logs/DiagnosticReports"
  "$HOME/Library/Application Support/CrashReporter"

  # Flutter / Dart
  "$HOME/.pub-cache"
  "$HOME/.dartServer"
  "$HOME/.flutter"
  "$HOME/.flutter-devtools"
  "$HOME/Flutter"
  "$HOME/fvm/versions"
  "$HOME/.fvm"

  # Android / Gradle / Kotlin
  "$HOME/.gradle/caches"
  "$HOME/.gradle/daemon"
  "$HOME/.gradle/wrapper/dists"
  "$HOME/.android/cache"
  "$HOME/.android/build-cache"
  "$HOME/.android/avd"
  "$HOME/Library/Android/sdk/system-images"
  "$HOME/Library/Android/sdk/ndk"
  "$HOME/Library/Android/sdk/emulator"
  "$HOME/.kotlin"
  "$HOME/.konan"

  # JetBrains / Android Studio
  "$HOME/Library/Caches/JetBrains"
  "$HOME/Library/Logs/JetBrains"
  "$HOME/Library/Caches/Google/AndroidStudio"
  "$HOME/Library/Logs/Google/AndroidStudio"

  # Ruby / Fastlane
  "$HOME/.bundle/cache"
  "$HOME/.gem"
  "$HOME/.rbenv/versions"

  # Node / npm / yarn
  "$HOME/.npm"
  "$HOME/.yarn/cache"
  "$HOME/.cache/yarn"
  "$HOME/Library/Caches/Yarn"
  "$HOME/.pnpm-store"

  # Homebrew
  "$HOME/Library/Caches/Homebrew"

  # Docker
  "$HOME/Library/Containers/com.docker.docker/Data/vms"

  # Browsers
  "$HOME/Library/Caches/Google/Chrome"
  "$HOME/Library/Caches/com.apple.Safari"

  # User content
  "$HOME/Downloads"
  "$HOME/Documents"
  "$HOME/.Trash"
)

# Build list với size
list=()

echo "🔍 Scanning..."

for p in "${paths[@]}"; do
  if [ -d "$p" ]; then
    size=$(du -sh "$p" 2>/dev/null | awk '{print $1}')
    list+=("$size | $p")
  fi
done

# Sort theo size
sorted=$(printf "%s\n" "${list[@]}" | sort -hr)

# ───────────────────────────────────────────────────────────────
# READ-ONLY SCAN: các đường dẫn hệ thống Macintosh HD
# (chỉ log ra folder lớn, KHÔNG đưa vào danh sách xoá để tránh
#  phá hỏng hệ thống / cần sudo)
# ───────────────────────────────────────────────────────────────
scan_only_paths=(
  "/Applications"
  "/Library/Caches"
  "/Library/Logs"
  "/Library/Logs/DiagnosticReports"
  "/Library/Developer/CommandLineTools"
  "/Library/Developer/Xcode"
  "/Library/Android"
  "/Library/Java/JavaVirtualMachines"
  "/Library/Containers"
  "/Library/Group Containers"
  "/Library/Application Support"
  "/private/var/log"
  "/private/var/folders"
  "/private/var/db/diagnostics"
  "/private/var/vm"
  "/private/tmp"
  "/usr/local"
  "/usr/local/Cellar"
  "/usr/local/var"
  "/opt/homebrew"
  "/opt/homebrew/Cellar"
)

# Ngưỡng "folder lớn" — chỉ in nếu >= 500MB
SIZE_THRESHOLD_MB=500

echo ""
echo "📊 Quét read-only trên Macintosh HD (chỉ hiển thị folder >= ${SIZE_THRESHOLD_MB}MB):"
echo "------------------------------------------------------------"

system_report=()
for p in "${scan_only_paths[@]}"; do
  if [ -d "$p" ]; then
    # Lấy size theo KB (cột 1 của du -sk) để so sánh ngưỡng
    kb=$(du -sk "$p" 2>/dev/null | awk '{print $1}')
    if [ -n "$kb" ] && [ "$kb" -ge $((SIZE_THRESHOLD_MB * 1024)) ]; then
      human=$(du -sh "$p" 2>/dev/null | awk '{print $1}')
      system_report+=("$human | $p")
    fi
  fi
done

if [ ${#system_report[@]} -eq 0 ]; then
  echo "   (không có folder nào vượt ngưỡng)"
else
  printf "%s\n" "${system_report[@]}" | sort -hr | sed 's/^/   /'
fi
echo "------------------------------------------------------------"
echo "ℹ️  Các path trên chỉ để tham khảo — KHÔNG có trong danh sách xoá."
echo "    Một số (vd /Library, /private) cần sudo và có thể ảnh hưởng hệ thống."
echo ""

echo ""
echo "👉 Chọn folder cần xoá (TAB để chọn nhiều, ENTER để confirm):"
echo ""

# FZF multi select
selected=$(echo "$sorted" | fzf --multi --height=40% --reverse)

if [ -z "$selected" ]; then
  echo "❌ Không chọn gì"
  exit 0
fi

echo ""
echo "⚠️ Bạn đã chọn:"
echo "$selected"
echo ""

read -p "❓ Gõ DELETE để confirm: " confirm

if [ "$confirm" != "DELETE" ]; then
  echo "❌ Cancel"
  exit 0
fi

echo ""
echo "🧹 Cleaning..."

# Xoá từng folder
while read -r line; do
  path=$(echo "$line" | cut -d '|' -f2 | xargs)
  echo "➡️ Deleting: $path"
  rm -rf "$path"
done <<< "$selected"

echo "✅ Done"

# Optional: Flutter clean
echo ""
read -p "👉 Chạy flutter clean cho project hiện tại? (y/n): " fc

if [[ "$fc" == "y" || "$fc" == "Y" ]]; then
  echo "🧹 flutter clean..."
  flutter clean
  echo "✅ Flutter clean done"
fi

echo ""
echo "🎉 Hoàn tất!"