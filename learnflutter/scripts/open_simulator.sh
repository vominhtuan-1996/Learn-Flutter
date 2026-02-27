#!/bin/bash

# Script: open_simulator.sh
# Description: Open iOS Simulator with specific device configuration
# Usage: ./scripts/open_simulator.sh [device_name]

set -e

# Default device or use argument
DEVICE_NAME=${1:-"iPhone 15 Pro"}

echo "📱 Opening iOS Simulator: $DEVICE_NAME..."

# Check if Simulator is installed
if ! command -v xcrun &> /dev/null; then
    echo "❌ Error: Xcode command line tools not found"
    echo "Please install Xcode and command line tools"
    exit 1
fi

# Open Simulator app
echo "🚀 Launching Simulator app..."
open -a Simulator

# Wait for Simulator to launch
sleep 2

# Boot the specified device
echo "⚡ Booting device: $DEVICE_NAME..."
xcrun simctl boot "$DEVICE_NAME" 2>/dev/null || echo "Device already booted or not found"

# List available devices
echo ""
echo "📋 Available devices:"
xcrun simctl list devices | grep -v "unavailable"

echo ""
echo "✅ Simulator opened!"
echo "💡 Tip: Use 'xcrun simctl list devices' to see all available devices"
