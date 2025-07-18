#!/bin/bash

# Device Deployment Script for DataSenderApp
# Usage: ./deploy_to_device.sh YOUR_DEVICE_UDID

set -e

# Check if UDID was provided
if [ -z "$1" ]; then
    echo "❌ Error: Please provide your device UDID"
    echo "Usage: ./deploy_to_device.sh YOUR_DEVICE_UDID"
    echo ""
    echo "To find your UDID:"
    echo "1. Open Xcode"
    echo "2. Go to Window → Devices and Simulators"
    echo "3. Select your iPhone"
    echo "4. Copy the Identifier (UDID)"
    exit 1
fi

DEVICE_UDID="$1"
echo "🚀 DataSenderApp Device Deployment Script"
echo "========================================"
echo "📱 Target Device: $DEVICE_UDID"

# Regenerate project
echo "📦 Regenerating Xcode project..."
xcodegen generate

# Clean build directory
echo "🧹 Cleaning build directory..."
rm -rf ./build

# Build for device
echo "🔨 Building app for device..."
xcodebuild build \
    -project DataSenderApp.xcodeproj \
    -scheme DataSenderApp \
    -destination "id=$DEVICE_UDID" \
    -derivedDataPath ./build \
    -configuration Debug

# Find the built app
APP_PATH="./build/Build/Products/Debug-iphoneos/DataSenderApp.app"

# Check if build succeeded
if [ ! -d "$APP_PATH" ]; then
    echo "❌ Build failed! App not found at expected location: $APP_PATH"
    exit 1
fi

# Install on device
echo "📲 Installing app on device..."
xcrun devicectl device install app --device "$DEVICE_UDID" "$APP_PATH"

# Launch the app
echo "🚀 Launching app..."
xcrun devicectl device process launch --device "$DEVICE_UDID" com.cjsjca.DataSenderApp.personal2025

echo "✅ Success! DataSenderApp is now running on your iPhone."
echo ""
echo "If you see 'Untrusted Developer' on your iPhone:"
echo "1. Go to Settings → General → VPN & Device Management"
echo "2. Find your developer profile and tap it"
echo "3. Tap 'Trust...'"