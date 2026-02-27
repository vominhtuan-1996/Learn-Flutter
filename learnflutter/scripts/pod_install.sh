#!/bin/bash

# Script: pod_install.sh
# Description: Install CocoaPods dependencies for iOS
# Usage: ./scripts/pod_install.sh

set -e

echo "📦 Installing CocoaPods dependencies..."

# Navigate to project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

# Check if CocoaPods is installed
if ! command -v pod &> /dev/null; then
    echo "❌ Error: CocoaPods is not installed"
    echo "Please install CocoaPods: sudo gem install cocoapods"
    exit 1
fi

# Navigate to iOS directory
cd ios

# Update pod repo (optional, uncomment if needed)
# echo "🔄 Updating CocoaPods repo..."
# pod repo update

# Install pods
echo "📥 Installing pods..."
pod install

# Deintegrate and reinstall if needed (uncomment if having issues)
# echo "🔄 Deintegrating and reinstalling pods..."
# pod deintegrate
# pod install

cd "$PROJECT_ROOT"

echo "✅ CocoaPods installation complete!"
