#!/bin/bash

# Script: fastlane.sh
# Description: Wrapper script for Fastlane commands
# Usage: ./scripts/fastlane.sh [lane] [platform]
# Example: ./scripts/fastlane.sh beta ios

set -e

# Get arguments
LANE=${1:-"beta"}
PLATFORM=${2:-"ios"}

echo "🚀 Running Fastlane..."
echo "Platform: $PLATFORM"
echo "Lane: $LANE"

# Navigate to project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

# Check if Fastlane is installed
if ! command -v fastlane &> /dev/null; then
    echo "❌ Error: Fastlane is not installed"
    echo "Please install Fastlane: sudo gem install fastlane"
    exit 1
fi

# Check if fastlane directory exists
if [ ! -d "fastlane" ]; then
    echo "❌ Error: fastlane directory not found"
    echo "Please initialize Fastlane first: fastlane init"
    exit 1
fi

# Navigate to platform directory
case $PLATFORM in
    ios)
        cd ios
        echo "📱 Running iOS Fastlane lane: $LANE"
        ;;
    android)
        cd android
        echo "🤖 Running Android Fastlane lane: $LANE"
        ;;
    *)
        echo "❌ Unknown platform: $PLATFORM"
        echo "Available platforms: ios, android"
        exit 1
        ;;
esac

# Run Fastlane
fastlane $LANE

cd "$PROJECT_ROOT"

echo "✅ Fastlane completed successfully!"
