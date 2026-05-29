#!/bin/bash
# Cài git pre-commit hook chặn commit nhầm các file auto-generated.
set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HOOK_FILE="$PROJECT_ROOT/.git/hooks/pre-commit"

cat > "$HOOK_FILE" <<'EOF'
#!/bin/bash
# Chặn commit các file auto-generated (sẽ gây mismatch giữa dev).
BLOCKED=(
  "ios/Runner/GeneratedPluginRegistrant.h"
  "ios/Runner/GeneratedPluginRegistrant.m"
  "ios/Flutter/Generated.xcconfig"
  "ios/Flutter/flutter_export_environment.sh"
  "android/app/src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java"
  ".flutter-plugins"
  ".flutter-plugins-dependencies"
)

# Chỉ block ADD/MODIFY/RENAME, KHÔNG block DELETE (xoá khỏi tracking là OK).
STAGED=$(git diff --cached --name-only --diff-filter=AMR)
FOUND=""
for f in "${BLOCKED[@]}"; do
  if echo "$STAGED" | grep -qx "$f"; then
    FOUND="$FOUND\n  - $f"
  fi
done

if [ -n "$FOUND" ]; then
  echo "❌ Phát hiện file auto-generated trong staging:"
  echo -e "$FOUND"
  echo ""
  echo "Các file này phải được Flutter tool regenerate mỗi khi pubspec thay đổi."
  echo "Đừng commit. Unstage bằng:"
  echo "  git restore --staged <file>"
  exit 1
fi
EOF

chmod +x "$HOOK_FILE"
echo "✅ Installed pre-commit hook at $HOOK_FILE"
