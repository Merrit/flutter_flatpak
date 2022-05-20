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
      _dBusInterface.themePreferenceStream.map((event) {
        switch (event) {
          case 1:
            return ThemeMode.dark;
          case 2:
            return ThemeMode.light;
          default:
            return null;
        }
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

    switch (themePreference) {
      case 1:
        return ThemeMode.dark;
      case 2:
        return ThemeMode.light;
      default:
        return null;
    }
  }
}
