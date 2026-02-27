#!/bin/bash

# Script: clean_ios.sh
# Description: Clean iOS build artifacts and derived data
# Usage: ./scripts/clean_ios.sh

set -e

echo "🧹 Cleaning iOS build artifacts..."

# Navigate to project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

# Clean Flutter build
echo "📦 Cleaning Flutter build..."
flutter clean

# Clean iOS build artifacts
echo "🍎 Cleaning iOS build artifacts..."
cd ios

# Remove build directory
if [ -d "build" ]; then
    echo "  - Removing build directory..."
    rm -rf build
fi

# Remove Pods directory
if [ -d "Pods" ]; then
    echo "  - Removing Pods directory..."
    rm -rf Pods
fi

# Remove Podfile.lock
if [ -f "Podfile.lock" ]; then
    echo "  - Removing Podfile.lock..."
    rm -f Podfile.lock
fi

# Remove .symlinks
if [ -d ".symlinks" ]; then
    echo "  - Removing .symlinks..."
    rm -rf .symlinks
fi

# Clean derived data
echo "🗑️  Cleaning Xcode derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*

cd "$PROJECT_ROOT"

echo "✅ iOS cleanup complete!"
