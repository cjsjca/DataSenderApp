#!/bin/bash

# Simulator Deployment Script for DataSenderApp
# Usage: ./deploy_to_device.sh

set -e

echo "🚀 DataSenderApp Simulator Deployment Script"
echo "==========================================="

# Regenerate project
echo "📦 Regenerating Xcode project..."
xcodegen generate

# Boot simulator
echo "📱 Booting iPhone 16 Pro simulator..."
xcrun simctl boot "iPhone 16 Pro" 2>/dev/null || echo "Simulator already booted"

# Wait a moment for simulator to be ready
sleep 2

# Clean build directory
echo "🧹 Cleaning build directory..."
rm -rf ./build

# Build for simulator
echo "🔨 Building app for simulator..."
xcodebuild build \
    -project DataSenderApp.xcodeproj \
    -scheme DataSenderApp \
    -destination "platform=iOS Simulator,name=iPhone 16 Pro,OS=18.5" \
    -derivedDataPath ./build \
    -configuration Debug \
    -quiet

# Find the built app
APP_PATH="./build/Build/Products/Debug-iphonesimulator/DataSenderApp.app"

# Check if build succeeded
if [ ! -d "$APP_PATH" ]; then
    echo "❌ Build failed! App not found at expected location: $APP_PATH"
    exit 1
fi

# Install on simulator
echo "📲 Installing app on simulator..."
xcrun simctl install booted "$APP_PATH"

# Launch the app
echo "🚀 Launching app..."
xcrun simctl launch booted com.cjsjca.DataSenderApp

echo "✅ Success! DataSenderApp is now running in the iPhone 16 Pro simulator."
echo ""
echo "To open the Simulator app window:"
echo "open -a Simulator"