#!/bin/bash

# Script: build_xcframework.sh
# Description: Build XCFramework for iOS distribution
# Usage: ./scripts/build_xcframework.sh

set -e

echo "🏗️  Building XCFramework..."

# Navigate to project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

# Configuration
SCHEME_NAME="Runner"
FRAMEWORK_NAME="App"
OUTPUT_DIR="$PROJECT_ROOT/build/xcframework"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Navigate to iOS directory
cd ios

echo "📱 Building for iOS devices..."
xcodebuild archive \
    -workspace Runner.xcworkspace \
    -scheme "$SCHEME_NAME" \
    -configuration Release \
    -destination 'generic/platform=iOS' \
    -archivePath "$OUTPUT_DIR/ios.xcarchive" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES

echo "💻 Building for iOS Simulator..."
xcodebuild archive \
    -workspace Runner.xcworkspace \
    -scheme "$SCHEME_NAME" \
    -configuration Release \
    -destination 'generic/platform=iOS Simulator' \
    -archivePath "$OUTPUT_DIR/ios-simulator.xcarchive" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES

echo "📦 Creating XCFramework..."
xcodebuild -create-xcframework \
    -framework "$OUTPUT_DIR/ios.xcarchive/Products/Library/Frameworks/$FRAMEWORK_NAME.framework" \
    -framework "$OUTPUT_DIR/ios-simulator.xcarchive/Products/Library/Frameworks/$FRAMEWORK_NAME.framework" \
    -output "$OUTPUT_DIR/$FRAMEWORK_NAME.xcframework"

cd "$PROJECT_ROOT"

echo "✅ XCFramework built successfully!"
echo "📍 Output: $OUTPUT_DIR/$FRAMEWORK_NAME.xcframework"
