#!/bin/bash
# Download ML models to assets/models/
# Run from project root: bash scripts/download_models.sh

set -e
DEST="$(dirname "$0")/../assets/models"
mkdir -p "$DEST"

echo "=== Downloading ML models to $DEST ==="

# 1. MiDaS v2.1 small — monocular depth estimation (64MB)
MIDAS="$DEST/midas_v21_small_256.onnx"
if [ -f "$MIDAS" ] && [ "$(wc -c < "$MIDAS")" -gt 1000000 ]; then
  echo "[SKIP] midas_v21_small_256.onnx already exists"
else
  echo "[DOWN] MiDaS v2.1 small (~64MB)..."
  curl -L "https://github.com/isl-org/MiDaS/releases/download/v2_1/model-small.onnx" \
    -o "$MIDAS" --progress-bar
  echo "[OK]   midas_v21_small_256.onnx"
fi

# 2. Product detector + labels — copy from pms_sdk (local)
PMS_SRC="/Users/tuanios_su12/pms_sdk/lib/assets/models"
if [ -d "$PMS_SRC" ]; then
  echo "[COPY] detector.onnx + labels.txt from pms_sdk..."
  cp "$PMS_SRC/detector.onnx" "$DEST/detector.onnx"
  cp "$PMS_SRC/labels.txt"    "$DEST/labels.txt"
  echo "[OK]   detector.onnx + labels.txt"
else
  echo "[WARN] pms_sdk not found at $PMS_SRC — skip detector model"
fi

echo ""
echo "=== Done ==="
ls -lh "$DEST"
