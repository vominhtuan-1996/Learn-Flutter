#!/bin/bash
set -e
# Always run from project root (parent of fastlane/)
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔥 Starting Shorebird OTA Patch for iOS & Android..."

# Extract flutter version from .fvmrc if it exists
if [ -f .fvmrc ]; then
  FLUTTER_VERSION=$(grep '"flutter":' .fvmrc | sed -E 's/.*"flutter": *"([^"]+)".*/\1/')
  echo "🎯 Detected FVM Flutter version: $FLUTTER_VERSION"
  shorebird patch ios --flutter-version=$FLUTTER_VERSION
  shorebird patch android --flutter-version=$FLUTTER_VERSION
else
  echo "⚠️ .fvmrc not found, using default Shorebird Flutter version"
  shorebird patch ios
  shorebird patch android
fi

echo "✅ OTA Patch Pipeline Completed for both platforms!"
