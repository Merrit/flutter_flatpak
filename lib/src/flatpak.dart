import 'dart:io';

import 'package:flutter/material.dart';

import 'dbus_interface/dbus_interface.dart';

/// Interface to Flatpak-specific parts of a Flutter application.
class Flatpak {
  /// Since Flatpak is in a sandbox we get theme preference from dbus.
  final DBusInterface _dBusInterface;

  const Flatpak._(this._dBusInterface);

  /// Returns null if not running inside a Flatpak sandbox.
  static Flatpak? init({DBusInterface? dBusInterface}) {
    final flatpakId = Platform.environment['FLATPAK_ID'];
    if (flatpakId == null) return null;

    return Flatpak._(dBusInterface ?? DBusInterface());
  }

  /// A stream of [ThemeMode].
  ///
  /// Emits whenever the system preference for theme mode changes. This
  /// allows subscribing to changes so the Flutter app can update
  /// its theme dynamically in real-time, as native apps do.
  ///
  /// If there is an issue parsing the theme the return will be null.
  Stream<ThemeMode?> get themeModeStream =>
      _dBusInterface.themePreferenceStream.map((int themePreference) {
        return _intToThemeMode(themePreference);
      });

  /// Returns `null` if if the theme is unknown or
  /// the system does not support this feature.

  /// Returns a [ThemeMode] based on the system's theme preference.
  ///
  /// If there is an issue getting the system's theme preference,
  /// for example if the system does not yet support the interface,
  /// the return will be null.
  Future<ThemeMode?> systemThemeMode() async {
    final themePreference = await _dBusInterface.readThemePreference();
    if (themePreference == null) return null;

    return _intToThemeMode(themePreference);
  }
}

ThemeMode? _intToThemeMode(int value) {
  switch (value) {
    case 1:
      return ThemeMode.dark;
    case 2:
      return ThemeMode.light;
    case 0:
      // 0 is *supposed* to be "No preference", however all
      // current implementations seem to treat it as light preference -
      // basically returning 1 for dark and 0 for light, never bothering
      // to ever return 2 as they are supposed to. ¯\_(ツ)_/¯
      return ThemeMode.light;
    default:
      return null;
  }
}
