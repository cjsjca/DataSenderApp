#!/bin/bash

# Clean and build the app first
xcodebuild clean build \
  -project DataSenderApp.xcodeproj \
  -scheme DataSenderApp \
  -destination "platform=iOS Simulator,name=iPhone 16,OS=18.5" \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO

# Build the test target separately without linking to debug dylib
xcodebuild build-for-testing \
  -project DataSenderApp.xcodeproj \
  -scheme DataSenderApp \
  -destination "platform=iOS Simulator,name=iPhone 16,OS=18.5" \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO \
  OTHER_LDFLAGS=""

# Run the tests without building
xcodebuild test-without-building \
  -project DataSenderApp.xcodeproj \
  -scheme DataSenderApp \
  -destination "platform=iOS Simulator,name=iPhone 16,OS=18.5" \
  -configuration Debug