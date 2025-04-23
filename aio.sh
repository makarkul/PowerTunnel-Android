#!/bin/bash

set -x

export POWER_TUNNEL_ROOT=/Users/makarand/PowerTunnel
export POWER_TUNNEL_ANDROID_ROOT=/Users/makarand/PowerTunnel-Android
export PLUGINS_ROOT=/Users/makarand/PowerTunnel-Android-Plugins


cd $POWER_TUNNEL_ROOT
gradlew clean build
cp $POWER_TUNNEL_ROOT/desktop/build/run/plugins/cache-plugin-2.0.jar $PLUGINS_ROOT/androidify
cd $PLUGINS_ROOT/androidify
test.sh
cp $PLUGINS_ROOT/androidify/cache-plugin-2.0-Androidified.jar $POWER_TUNNEL_ANDROID_ROOT/app/src/main/assets/plugins
cd $POWER_TUNNEL_ANDROID_ROOT
install_app.sh








