/*
 * This file is part of PowerTunnel-Android.
 *
 * PowerTunnel-Android is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */

package io.github.krlvm.powertunnel.android.utility;

import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Build;

public class FeatureUtility {
    public static boolean isQuickSettingsSupported() {
        return Build.VERSION.SDK_INT >= Build.VERSION_CODES.N;
    }

    public static boolean isQuickSettingsAvailable(Context context) {
        if (!isQuickSettingsSupported()) {
            return false;
        }
        return context.getPackageManager().hasSystemFeature("android.software.quicksettings");
    }
}
