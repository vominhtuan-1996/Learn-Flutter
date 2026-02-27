#!/bin/bash

FLUTTER_3274="$HOME/flutter_sdk_3.27.4"
FLUTTER_3328="$HOME/flutter_3.32.8"
FLUTTER_3293="$HOME/flutter_sdks/flutter_3.29.3"

SHELL_RC="$HOME/.zshrc" # dùng zsh

if [ -z "$1" ]; then
  echo "❌ Usage: $0 {3.27.4|3.32.8|3.29.3}"
  exit 1
fi

set_global_flutter() {
  local flutter_root=$1

  # Xóa config cũ
  sed -i.bak '/FLUTTER_ROOT/d' "$SHELL_RC"
  sed -i.bak '/flutter\/bin/d' "$SHELL_RC"

  # Thêm config mới
  {
    echo "export FLUTTER_ROOT=$flutter_root"
    echo 'export PATH=$FLUTTER_ROOT/bin:$PATH'
  } >> "$SHELL_RC"

  echo "✅ Global Flutter SDK switched to $flutter_root"
  echo "👉 Mở terminal mới rồi chạy: flutter --version"
}

case $1 in
  3.27.4) set_global_flutter "$FLUTTER_3274" ;;
  3.32.8) set_global_flutter "$FLUTTER_3328" ;;
  3.29.3) set_global_flutter "$FLUTTER_3293" ;;
  *)
    echo "❌ Unknown version: $1"
    echo "Available: 3.27.4 | 3.32.8 | 3.29.3"
    exit 1
    ;;
esac

#./switch_flutter.sh 3.27.4