#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status
set -o pipefail  # Return value of a pipeline is the value of the last command to exit with non-zero status

# Function to handle errors
handle_error() {
    echo "ERROR: Build failed at line $1"
    exit 1
}

# Set up error trap
trap 'handle_error $LINENO' ERR

echo "=== Starting PowerTunnel Android build process ==="

# Set environment variables
export POWER_TUNNEL_ROOT=/Users/makarand/PowerTunnel
export POWER_TUNNEL_ANDROID_ROOT=/Users/makarand/PowerTunnel-Android
export PLUGINS_ROOT=/Users/makarand/PowerTunnel-Android-Plugins

echo "=== Building PowerTunnel SDK ==="
cd "$POWER_TUNNEL_ROOT" || handle_error $LINENO

# Ensure gradlew is executable
if [ ! -x "$POWER_TUNNEL_ROOT/gradlew" ]; then
    echo "Making gradlew executable..."
    chmod +x "$POWER_TUNNEL_ROOT/gradlew"
fi

# Build SDK
echo "Building SDK..."
"$POWER_TUNNEL_ROOT/gradlew" :sdk:clean :sdk:build :sdk:jar || handle_error $LINENO

# Note: We don't copy the SDK JAR directly to the Android project
# because it's already included in the core-all.jar

echo "=== Building PowerTunnel core ==="
# Build core with updated SDK
echo "Building core module..."
"$POWER_TUNNEL_ROOT/gradlew" :core:clean :core:build || handle_error $LINENO

# Build fat JAR for core
echo "Building fat JAR for core..."
"$POWER_TUNNEL_ROOT/gradlew" :core:fatJar || handle_error $LINENO

# Copy core JAR to Android project
echo "Copying core JAR to Android project..."
cp "$POWER_TUNNEL_ROOT/core/build/libs/core-2.5.2-all.jar" "$POWER_TUNNEL_ANDROID_ROOT/app/libs/" || handle_error $LINENO

# Build PowerTunnel with all components
echo "Building complete PowerTunnel project..."
"$POWER_TUNNEL_ROOT/gradlew" clean build || handle_error $LINENO

echo "=== Processing plugins ==="
# Check if the JAR file exists before copying
if [ ! -f "$POWER_TUNNEL_ROOT/desktop/build/run/plugins/cache-plugin-2.0.jar" ]; then
    echo "ERROR: cache-plugin-2.0.jar not found!"
    exit 1
fi

# Copy plugin JAR
cp "$POWER_TUNNEL_ROOT/desktop/build/run/plugins/cache-plugin-2.0.jar" "$PLUGINS_ROOT/androidify/" || handle_error $LINENO

# Process plugin
cd "$PLUGINS_ROOT/androidify" || handle_error $LINENO

# Ensure test.sh is executable
if [ ! -x "$PLUGINS_ROOT/androidify/test.sh" ]; then
    echo "Making test.sh executable..."
    chmod +x "$PLUGINS_ROOT/androidify/test.sh"
fi

# Run test script
"$PLUGINS_ROOT/androidify/test.sh" || handle_error $LINENO

echo "=== Preparing Android app ==="
# Check if the Androidified JAR exists
if [ ! -f "$PLUGINS_ROOT/androidify/cache-plugin-2.0-Androidified.jar" ]; then
    echo "ERROR: cache-plugin-2.0-Androidified.jar not found!"
    exit 1
fi

# Create assets directory if it doesn't exist
mkdir -p "$POWER_TUNNEL_ANDROID_ROOT/app/src/main/assets/plugins"

# Copy Androidified plugin
cp "$PLUGINS_ROOT/androidify/cache-plugin-2.0-Androidified.jar" "$POWER_TUNNEL_ANDROID_ROOT/app/src/main/assets/plugins/" || handle_error $LINENO

echo "=== Building and installing Android app ==="
cd "$POWER_TUNNEL_ANDROID_ROOT" || handle_error $LINENO

# Ensure install_app.sh is executable
if [ ! -x "$POWER_TUNNEL_ANDROID_ROOT/install_app.sh" ]; then
    echo "Making install_app.sh executable..."
    chmod +x "$POWER_TUNNEL_ANDROID_ROOT/install_app.sh"
fi

# Run install script
"$POWER_TUNNEL_ANDROID_ROOT/install_app.sh" || handle_error $LINENO

echo "=== Build process completed successfully ==="








