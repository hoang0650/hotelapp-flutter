@echo off
cd /d "%~dp0"

echo ========================================
echo Checking for connected devices
echo ========================================
echo.

echo Checking Flutter devices...
flutter devices
echo.

echo Checking ADB devices (Android)...
adb devices
echo.

echo ========================================
echo Instructions:
echo ========================================
echo.
echo If you don't see your phone:
echo.
echo 1. Connect your phone via USB
echo 2. Enable USB Debugging on your phone:
echo    - Settings ^> About phone ^> Tap "Build number" 7 times
echo    - Settings ^> Developer options ^> Enable "USB debugging"
echo 3. On your phone, accept "Allow USB debugging" prompt
echo 4. Run this script again
echo.
echo For detailed instructions, see RUN_ON_PHONE.md
echo.
pause

