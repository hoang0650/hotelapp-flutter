#!/bin/bash

echo "========================================"
echo "iOS Setup Script for Flutter"
echo "========================================"
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "ERROR: This script must be run on macOS!"
    echo "iOS development requires macOS and Xcode."
    exit 1
fi

echo "Step 1: Checking Xcode installation..."
if ! command -v xcodebuild &> /dev/null; then
    echo "ERROR: Xcode is not installed!"
    echo "Please install Xcode from the App Store."
    exit 1
fi

xcodebuild -version
echo ""

echo "Step 2: Checking Xcode Command Line Tools..."
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -license accept
echo ""

echo "Step 3: Checking CocoaPods..."
if ! command -v pod &> /dev/null; then
    echo "CocoaPods not found. Installing..."
    sudo gem install cocoapods
else
    echo "CocoaPods is installed: $(pod --version)"
fi
echo ""

echo "Step 4: Installing iOS dependencies..."
cd ios
pod install
cd ..
echo ""

echo "Step 5: Checking connected devices..."
flutter devices
echo ""

echo "========================================"
echo "Setup complete!"
echo "========================================"
echo ""
echo "Next steps:"
echo "1. Connect your iPhone via USB"
echo "2. Trust the computer on your iPhone"
echo "3. Open ios/Runner.xcworkspace in Xcode"
echo "4. Configure Signing & Capabilities"
echo "5. Run: flutter run"
echo ""
echo "For detailed instructions, see RUN_ON_PHONE.md"
echo ""

