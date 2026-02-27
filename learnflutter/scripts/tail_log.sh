#!/bin/bash

# Script: tail_log.sh
# Description: Tail and monitor application logs
# Usage: ./scripts/tail_log.sh [log_type]
# Log types: flutter, ios, android

set -e

# Get log type from argument or use default
LOG_TYPE=${1:-"flutter"}

echo "📋 Monitoring $LOG_TYPE logs..."

# Navigate to project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

case $LOG_TYPE in
    flutter)
        echo "🐦 Tailing Flutter logs..."
        echo "💡 Run 'flutter run' in another terminal first"
        echo ""
        # Flutter logs are typically shown in the terminal where flutter run is executed
        # This will show recent logs if available
        if [ -f "flutter_logs.txt" ]; then
            tail -f flutter_logs.txt
        else
            echo "No flutter_logs.txt found. Logs are shown in the terminal where 'flutter run' is executed."
        fi
        ;;
    
    ios)
        echo "🍎 Tailing iOS Simulator logs..."
        # Get the most recently booted simulator
        DEVICE_ID=$(xcrun simctl list devices | grep "Booted" | head -1 | grep -o '[A-F0-9-]\{36\}')
        
        if [ -z "$DEVICE_ID" ]; then
            echo "❌ No booted simulator found"
            echo "Please start a simulator first using: ./scripts/open_simulator.sh"
            exit 1
        fi
        
        echo "Device ID: $DEVICE_ID"
        echo ""
        xcrun simctl spawn "$DEVICE_ID" log stream --predicate 'processImagePath endswith "Runner"' --level debug
        ;;
    
    android)
        echo "🤖 Tailing Android logs..."
        if ! command -v adb &> /dev/null; then
            echo "❌ Error: adb not found"
            echo "Please install Android SDK and add adb to PATH"
            exit 1
        fi
        
        # Clear previous logs and start monitoring
        adb logcat -c
        adb logcat | grep -i flutter
        ;;
    
    *)
        echo "❌ Unknown log type: $LOG_TYPE"
        echo "Available types: flutter, ios, android"
        exit 1
        ;;
esac
