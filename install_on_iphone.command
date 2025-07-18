#!/bin/bash

echo "🚀 Installing DataSenderApp on iPhone"
echo "===================================="

cd "$(dirname "$0")"

# First, open Xcode to ensure provisioning profiles are created
echo "📱 Opening Xcode to manage signing..."
open -a Xcode DataSenderApp.xcodeproj

echo ""
echo "⚠️  IMPORTANT: In Xcode, please:"
echo "1. Select your iPhone from the device dropdown"
echo "2. Click the Run button (▶️)"
echo "3. If you see any signing errors, click 'Try Again'"
echo "4. Trust the developer certificate on your iPhone if prompted"
echo ""
echo "Xcode will handle all the provisioning profile creation automatically."
echo ""
echo "Press any key to close this window after the app is running on your iPhone..."
read -n 1