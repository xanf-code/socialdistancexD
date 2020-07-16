package com.darshanxD.covidtracker;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodChannel;

import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Bundle;

import android.provider.Settings;
import android.bluetooth.BluetoothAdapter;


public class MainActivity extends FlutterActivity {


  private static final String CHANNEL = "samples.flutter.dev/battery";

  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine);
    new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
      .setMethodCallHandler(
        (call, result) -> {
          // Note: this method is invoked on the main thread.
          if (call.method.equals("getBatteryLevel")) {
            String batteryLevel = getBatteryLevel();

            if (!batteryLevel.equals("")) {
              result.success(batteryLevel);
            } else {
              result.error("UNAVAILABLE", "Battery level not available.", null);
            }
          } else {
            result.notImplemented();
          }
        }
      );
  }

  private String getBatteryLevel() {

    String last = Settings.System.getString(getContentResolver(), "bluetooth_name");
    if(last != null) {
      return last;
    }
    last = Settings.Secure.getString(getContentResolver(), "bluetooth_name");
    if(last != null) {
      return last;
    }
    last = BluetoothAdapter.getDefaultAdapter().getName();
    if(last != null) {
      return last;
    }
    last = Settings.System.getString(getContentResolver(), "device_name");
    if(last != null) {
      return last;
    }

    return "";
  }
}
