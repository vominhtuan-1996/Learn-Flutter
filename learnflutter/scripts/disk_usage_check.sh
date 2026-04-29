#!/bin/bash

echo "🔍 Scanning disk usage..."
echo "----------------------------------"

# Tổng dung lượng HOME
echo "📦 Total usage in HOME:"
du -sh ~ 2>/dev/null

echo ""
echo "📁 Top folders in HOME:"
du -sh ~/* 2>/dev/null | sort -h

echo ""
echo "📁 Top folders in ~/Library:"
du -sh ~/Library/* 2>/dev/null | sort -h

echo ""
echo "📁 Top folders in Developer (Xcode, Simulator):"
du -sh ~/Library/Developer/* 2>/dev/null | sort -h

echo ""
echo "📁 Top caches:"
du -sh ~/Library/Caches/* 2>/dev/null | sort -h

echo ""
echo "📁 Top Flutter / Dart:"
du -sh ~/.pub-cache 2>/dev/null
du -sh ~/flutter 2>/dev/null

echo ""
echo "📁 Top iOS Simulator:"
du -sh ~/Library/Developer/CoreSimulator 2>/dev/null

echo ""
echo "📁 Top Xcode DerivedData:"
du -sh ~/Library/Developer/Xcode/DerivedData 2>/dev/null

echo ""
echo "📁 Top Xcode Archives:"
du -sh ~/Library/Developer/Xcode/Archives 2>/dev/null

echo ""
echo "----------------------------------"
echo "✅ Scan complete"