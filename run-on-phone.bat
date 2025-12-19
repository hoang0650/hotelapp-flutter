@echo off
cd /d "%~dp0"

echo ========================================
echo Running Flutter app on phone
echo ========================================
echo.

echo Step 1: Checking devices...
flutter devices
echo.

echo Step 2: Running app...
echo.
echo If your phone is connected, the app will start automatically.
echo If not, please:
echo   1. Connect your phone via USB
echo   2. Enable USB debugging
echo   3. Run check-device.bat first
echo.

flutter run
if %errorlevel% neq 0 (
    echo.
    echo ERROR: Failed to run app!
    echo.
    echo Troubleshooting:
    echo 1. Make sure your phone is connected and USB debugging is enabled
    echo 2. Run: check-device.bat
    echo 3. See: RUN_ON_PHONE.md for detailed instructions
    echo.
    pause
    exit /b %errorlevel%
)

pause

