#!/bin/bash

echo "========================================"
echo "Running Flutter app on iOS"
echo "========================================"
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "ERROR: iOS development requires macOS!"
    echo "Please run this on a Mac computer."
    exit 1
fi

echo "Step 1: Checking devices..."
flutter devices
echo ""

echo "Step 2: Running app..."
echo ""
echo "If your iPhone is connected, the app will start automatically."
echo "If not, please:"
echo "  1. Connect your iPhone via USB"
echo "  2. Trust the computer on your iPhone"
echo "  3. Configure Signing in Xcode (ios/Runner.xcworkspace)"
echo "  4. See RUN_ON_PHONE.md for detailed instructions"
echo ""

flutter run

if [ $? -ne 0 ]; then
    echo ""
    echo "ERROR: Failed to run app!"
    echo ""
    echo "Troubleshooting:"
    echo "1. Make sure your iPhone is connected and trusted"
    echo "2. Run: ./setup-ios.sh"
    echo "3. Open ios/Runner.xcworkspace in Xcode"
    echo "4. Configure Signing & Capabilities"
    echo "5. See: RUN_ON_PHONE.md for detailed instructions"
    echo ""
    exit 1
fi

