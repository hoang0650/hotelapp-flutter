@echo off
cd /d "%~dp0"

echo ========================================
echo Hotel App Flutter - Quick Start
echo ========================================
echo.

echo Step 1: Checking Flutter installation...
flutter doctor
if %errorlevel% neq 0 (
    echo.
    echo ERROR: Flutter is not installed or not in PATH!
    echo Please install Flutter from: https://flutter.dev/docs/get-started/install
    pause
    exit /b %errorlevel%
)
echo.

echo Step 2: Getting dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo.
    echo ERROR: Failed to get dependencies!
    pause
    exit /b %errorlevel%
)
echo.

echo Step 3: Checking available devices...
flutter devices
echo.

echo ========================================
echo Setup complete!
echo ========================================
echo.
echo To run the app, use one of these commands:
echo.
echo   flutter run                    - Run on any available device
echo   flutter run -d <device-id>     - Run on specific device
echo.
echo To build APK:
echo   flutter build apk
echo.
echo For more information, see README.md or QUICK_START.md
echo.
pause

