#!/bin/bash
set -e

# Always run from project root (parent of fastlane/)
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🚀 Starting iOS Shorebird Release..."

# Extract flutter version from .fvmrc if it exists
if [ -f .fvmrc ]; then
  FLUTTER_VERSION=$(grep -o '"flutter": "[^"]*' .fvmrc | cut -d'"' -f4)
  echo "🎯 Detected FVM Flutter version: $FLUTTER_VERSION"
  shorebird release ios --flutter-version=$FLUTTER_VERSION --export-method enterprise --no-codesign
else
  echo "⚠️ .fvmrc not found, using default Shorebird Flutter version"
  shorebird release ios --flutter-version=3.29.3 --export-method enterprise --no-codesign
fi

echo "🌊 Starting Fastlane Enterprise Build for iOS..."
bundle exec fastlane ios enterprise

echo "✅ iOS Release Pipeline Completed!"
