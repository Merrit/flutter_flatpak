library flutter_flatpak;

import 'dart:io';

import 'package:flutter/material.dart';

class Flatpak {
  /// The system's theme preference, light or dark.
  final ThemeMode themeMode;

  const Flatpak._({
    required this.themeMode,
  });

  static Future<Flatpak?> init() async {
    final flatpakId = Platform.environment['FLATPAK_ID'];
    if (flatpakId == null) return null;

    return Flatpak._(
      themeMode: await _systemThemeMode(),
    );
  }

  /// Since Flatpak is in a sandbox we get theme preference from dbus.
  static Future<ThemeMode> _systemThemeMode() async {
    final result = await Process.run('bash', [
      '-c',
      "dbus-send --print-reply --dest=org.freedesktop.portal.Desktop /org/freedesktop/portal/desktop org.freedesktop.portal.Settings.Read string:'org.freedesktop.appearance' string:'color-scheme'"
    ]);

    final themeNumber = (result.stdout as String).trim().split('').last;

    ThemeMode themeMode;
    if (themeNumber == '2') {
      themeMode = ThemeMode.light;
    } else {
      themeMode = ThemeMode.dark;
    }

    return themeMode;
  }
}
