# Device Deployment Guide

## Prerequisites

1. **Apple Developer Account**: You need an active Apple Developer account (free or paid)
2. **Team ID**: Find your Team ID in Apple Developer Portal or Xcode
3. **Device UDID**: Get your device's UDID from Xcode or iTunes

## Setup Steps

### 1. Update Team ID

Edit `project.yml` and replace `YOUR_TEAM_ID` with your actual Apple Developer Team ID:

```yaml
DEVELOPMENT_TEAM: YOUR_TEAM_ID  # Replace with your actual Team ID (e.g., "ABC123DEF4")
```

You can find your Team ID:
- In Xcode: Preferences → Accounts → Your Apple ID → Team Details
- In Apple Developer Portal: Account → Membership → Team ID

### 2. Regenerate Project

```bash
xcodegen generate
```

### 3. Find Your Device UDID

Option A - Using Xcode:
```bash
xcrun devicectl list devices
```

Option B - Using Finder/iTunes:
1. Connect your iPhone
2. Open Finder (macOS Catalina+) or iTunes
3. Select your device
4. Click on device info to reveal UDID

### 4. Build and Install on Device

```bash
# Replace <YOUR_DEVICE_UDID> with your actual device UDID
xcodebuild build -project DataSenderApp.xcodeproj \
  -scheme DataSenderApp \
  -destination "id=<YOUR_DEVICE_UDID>" \
  -derivedDataPath ./build

# Install the app
xcrun devicectl device install app \
  --device <YOUR_DEVICE_UDID> \
  ./build/Build/Products/Debug-iphoneos/DataSenderApp.app
```

### 5. Launch on Device

```bash
xcrun devicectl device process launch \
  --device <YOUR_DEVICE_UDID> \
  --start-stopped com.cjsjca.DataSenderApp
```

## Troubleshooting

### "No account for team" error
- Make sure you're signed into Xcode with your Apple ID
- Verify the Team ID is correct

### "Device not found" error
- Ensure your device is connected and trusted
- Check that developer mode is enabled on your device (iOS 16+)

### "Code signing" error
- Open the project in Xcode once to let it download provisioning profiles
- Or manually download profiles: `xcodebuild -allowProvisioningUpdates`

## Alternative: Using Xcode GUI

If command line deployment fails:
1. Open `DataSenderApp.xcodeproj` in Xcode
2. Select your device from the device dropdown
3. Click Run (⌘R)

Xcode will handle provisioning profile creation automatically.