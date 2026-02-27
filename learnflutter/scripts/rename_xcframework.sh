#!/bin/bash

# Script: rename_xcframework.sh
# Description: Rename XCFramework files according to versioning conventions
# Usage: ./scripts/rename_xcframework.sh [version]

set -e

# Get version from argument or use default
VERSION=${1:-"1.0.0"}

echo "🏷️  Renaming XCFramework to version $VERSION..."

# Navigate to project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

# Configuration
FRAMEWORK_NAME="App"
OUTPUT_DIR="$PROJECT_ROOT/build/xcframework"
XCFRAMEWORK_PATH="$OUTPUT_DIR/$FRAMEWORK_NAME.xcframework"
NEW_NAME="$FRAMEWORK_NAME-$VERSION.xcframework"
NEW_PATH="$OUTPUT_DIR/$NEW_NAME"

# Check if XCFramework exists
if [ ! -d "$XCFRAMEWORK_PATH" ]; then
    echo "❌ Error: XCFramework not found at $XCFRAMEWORK_PATH"
    echo "Please build the XCFramework first using build_xcframework.sh"
    exit 1
fi

# Rename XCFramework
echo "📝 Renaming $FRAMEWORK_NAME.xcframework to $NEW_NAME..."
mv "$XCFRAMEWORK_PATH" "$NEW_PATH"

# Create zip archive
echo "📦 Creating zip archive..."
cd "$OUTPUT_DIR"
zip -r "$NEW_NAME.zip" "$NEW_NAME"

cd "$PROJECT_ROOT"

echo "✅ XCFramework renamed successfully!"
echo "📍 Framework: $NEW_PATH"
echo "📍 Archive: $OUTPUT_DIR/$NEW_NAME.zip"
