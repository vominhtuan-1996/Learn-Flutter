#!/bin/bash
set -e

# Always run from project root (parent of fastlane/)
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"


echo "🚀 Starting Android Shorebird Release..."

# Extract flutter version from .fvmrc if it exists
if [ -f .fvmrc ]; then
  FLUTTER_VERSION=$(grep '"flutter":' .fvmrc | sed -E 's/.*"flutter": *"([^"]+)".*/\1/')
  echo "🎯 Detected FVM Flutter version: $FLUTTER_VERSION"
  shorebird release android --flutter-version=$FLUTTER_VERSION
else
  echo "⚠️ .fvmrc not found, using default Shorebird Flutter version"
  shorebird release android
fi
echo "🌊 Starting Fastlane Enterprise Build for Android..."
bundle exec fastlane android enterprise

echo "✅ Android Release Pipeline Completed!"
