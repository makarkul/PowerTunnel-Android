#!/bin/bash

set -x

# Set environment variables (same as build_app.sh)
export ANDROID_HOME="/Users/makarand/Library/Android/sdk"

# App package name
APP_PACKAGE="io.github.krlvm.powertunnel.android.dev"
APK_PATH="app/build/outputs/apk/debug/app-debug.apk"

# Build the app first
echo "Building the app..."
./build_app.sh
if [ $? -ne 0 ]; then
    echo "Build failed. Aborting installation."
    exit 1
fi

# Check if APK exists
if [ ! -f "$APK_PATH" ]; then
    echo "Error: APK file not found at $APK_PATH"
    exit 1
fi

# Kill any running emulator
kill_emulator() {
    echo "Stopping any running emulator..."
    adb devices | grep emulator | cut -f1 | while read -r line; do
        adb -s "$line" emu kill
    done
    sleep 5
}

# Function to check if emulator is ready
check_emulator() {
    adb devices | grep -w "emulator-.*device" > /dev/null
    return $?
}

# Kill any existing emulator
kill_emulator

# Start new emulator in foreground
echo "Starting Medium_Phone_API_35 emulator in foreground..."
"$ANDROID_HOME/emulator/emulator" -avd Medium_Phone_API_35 -selinux permissive -no-snapshot-load &

# Wait for emulator to start (timeout after 2 minutes)
echo "Waiting for emulator to start..."
TIMEOUT=120
while [ $TIMEOUT -gt 0 ] && ! check_emulator; do
    echo -n "."
    sleep 2
    TIMEOUT=$((TIMEOUT - 2))
done
echo ""

if [ $TIMEOUT -le 0 ]; then
    echo "Error: Emulator failed to start within timeout period"
    exit 1
fi
echo "Emulator started successfully"

# Wait for system to be fully booted
echo "Waiting for system to fully boot..."
TIMEOUT=180
while [ $TIMEOUT -gt 0 ]; do
    if adb shell getprop sys.boot_completed 2>/dev/null | grep -q "1"; then
        echo "System is ready"
        # Give additional time for all services to start
        sleep 20
        break
    fi
    echo -n "."
    sleep 2
    TIMEOUT=$((TIMEOUT - 2))
done

if [ $TIMEOUT -le 0 ]; then
    echo "\nError: System boot timeout"
    exit 1
fi

# Uninstall existing app with data
echo "Uninstalling existing app..."
adb uninstall "$APP_PACKAGE"
sleep 3

# Set SELinux to permissive for debugging (not for production)
adb shell setenforce 0

# Install new APK
echo "Installing new APK..."
adb install "$APK_PATH"
if [ $? -eq 0 ]; then
    echo "Installation successful!"
    echo "Package: $APP_PACKAGE"
    echo "APK path: $APK_PATH"
else
    echo "Installation failed!"
    exit 1
fi

set +x
