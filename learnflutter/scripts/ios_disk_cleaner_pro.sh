#!/bin/bash

echo "🚀 iOS / Flutter Disk Cleaner PRO"
echo "----------------------------------"

# Danh sách folder phổ biến
paths=(
  "$HOME/Library/Developer/Xcode/DerivedData"
  "$HOME/Library/Developer/CoreSimulator"
  "$HOME/Library/Developer/Xcode/Archives"
  "$HOME/Library/Caches/com.apple.dt.Xcode"
  "$HOME/Library/Caches"
  "$HOME/.pub-cache"
  "$HOME/Flutter"
  "$HOME/Documents"
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