#!/bin/bash
# Shorebird OTA Patch — interactive version picker.
#
# Flow:
#   1. List tất cả release từ Shorebird Cloud.
#   2. User chọn 1 release version (qua fzf nếu có, hoặc menu số).
#   3. Auto patch iOS + Android cho version đó, KHÔNG có prompt nào nữa.
#
# Cờ env tuỳ chọn:
#   PLATFORM=ios|android|both   (mặc định: both)

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

PLATFORM=${PLATFORM:-both}

# ─── 1. Detect Flutter version ──────────────────────────────────────────────
if [ -f .fvmrc ]; then
  FLUTTER_VERSION=$(grep '"flutter":' .fvmrc | sed -E 's/.*"flutter": *"([^"]+)".*/\1/')
  echo "🎯 Flutter version: $FLUTTER_VERSION"
else
  FLUTTER_VERSION=3.29.3
  echo "⚠️ .fvmrc không tìm thấy, dùng default $FLUTTER_VERSION"
fi

# ─── 2. Fetch releases list ─────────────────────────────────────────────────
echo "📡 Lấy danh sách release từ Shorebird Cloud..."

# Lọc dòng "<id>  <version>  <status>  <flutter>" — bỏ log "Starting/Done"
RELEASES=$(shorebird releases list 2>/dev/null \
  | grep -E '^[0-9]+[[:space:]]+[0-9]+\.[0-9]+\.[0-9]+\+[0-9]+' \
  | awk '{ printf "%-10s  %-12s  %s\n", $1, $2, substr($0, index($0,$3)) }')

if [ -z "$RELEASES" ]; then
  echo "❌ Không có release nào. Tạo release trước bằng fastlane/release_*.sh."
  exit 1
fi

# ─── 3. Pick a version ──────────────────────────────────────────────────────
echo ""
echo "👇 Chọn release để patch (latest ở trên cùng):"
echo ""

if command -v fzf >/dev/null 2>&1; then
  SELECTED=$(echo "$RELEASES" | fzf \
    --height=60% --reverse --border \
    --header="ID         VERSION       PLATFORMS / FLUTTER" \
    --prompt="Pick release > ")
else
  # Fallback menu số
  IFS=$'\n' read -d '' -r -a LINES <<< "$RELEASES" || true
  printf "%-3s  %s\n" "#" "ID        VERSION       PLATFORMS / FLUTTER"
  for i in "${!LINES[@]}"; do
    printf "%-3s  %s\n" "$((i+1))" "${LINES[$i]}"
  done
  echo ""
  read -p "Nhập số thứ tự (1-${#LINES[@]}): " IDX
  if ! [[ "$IDX" =~ ^[0-9]+$ ]] || (( IDX < 1 || IDX > ${#LINES[@]} )); then
    echo "❌ Lựa chọn không hợp lệ."
    exit 1
  fi
  SELECTED="${LINES[$((IDX-1))]}"
fi

if [ -z "$SELECTED" ]; then
  echo "❌ Không chọn gì. Huỷ."
  exit 0
fi

# Parse version "x.y.z+build" (cột 2)
VERSION=$(echo "$SELECTED" | awk '{print $2}')

if [ -z "$VERSION" ]; then
  echo "❌ Không parse được version từ dòng: $SELECTED"
  exit 1
fi

echo ""
echo "✅ Đã chọn: release version $VERSION"
echo ""

# ─── 4. Auto patch — không prompt thêm ──────────────────────────────────────
COMMON_FLAGS="--release-version=$VERSION \
  --allow-native-diffs --allow-asset-diffs"

if [ "$PLATFORM" = "ios" ] || [ "$PLATFORM" = "both" ]; then
  echo "🍎 Patching iOS..."
  shorebird patch ios --export-method enterprise --no-codesign $COMMON_FLAGS
fi

if [ "$PLATFORM" = "android" ] || [ "$PLATFORM" = "both" ]; then
  echo "🤖 Patching Android..."
  shorebird patch android $COMMON_FLAGS
fi

echo ""
echo "✅ OTA Patch hoàn tất cho version $VERSION ($PLATFORM)."
