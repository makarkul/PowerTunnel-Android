#!/bin/bash

# Set environment variables
export ANDROID_HOME="/Users/makarand/Library/Android/sdk"
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"

# Run the Gradle build command
echo "Cleaning project..."
./gradlew clean

echo "Starting Gradle build..."
./gradlew assembleDebug

# Check the exit code of the Gradle command
if [ $? -eq 0 ]; then
  echo "Build successful!"
else
  echo "Build failed."
  exit 1
fi
