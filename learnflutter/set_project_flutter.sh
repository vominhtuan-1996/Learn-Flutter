#!/bin/bash
# Script: set_global_flutter.sh
# Usage: ./set_global_flutter.sh /path/to/flutter_sdk

NEW_FLUTTER_PATH=$1
SHELL_RC="$HOME/.zshrc"

if [ -z "$NEW_FLUTTER_PATH" ]; then
  echo "Usage: $0 /path/to/flutter_sdk"
  exit 1
fi

# Xoá dòng cũ nếu có
sed -i '' "/export FLUTTER_ROOT=/d" "$SHELL_RC"
sed -i '' "/\$FLUTTER_ROOT\/bin/d" "$SHELL_RC"

# Thêm dòng mới
echo "export FLUTTER_ROOT=$NEW_FLUTTER_PATH" >> "$SHELL_RC"
echo 'export PATH="$FLUTTER_ROOT/bin:$PATH"' >> "$SHELL_RC"

# Reload shell
source "$SHELL_RC"

echo "Flutter global SDK đã đổi sang $NEW_FLUTTER_PATH"
flutter --version
