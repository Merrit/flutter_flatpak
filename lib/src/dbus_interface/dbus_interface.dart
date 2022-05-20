import 'package:dbus/dbus.dart';
import 'package:flutter_flatpak/src/dbus_interface/org_freedesktop_portal_settings.dart';

class DBusInterface {
  final _settingsPortal = OrgFreedesktopPortalSettings(
    DBusClient.session(),
    'org.freedesktop.portal.Desktop',
    path: DBusObjectPath('/org/freedesktop/portal/desktop'),
  );

  Future<int?> readThemePreference() async {
    DBusVariant? result;
    try {
      result = await _settingsPortal.callRead(
        'org.freedesktop.appearance',
        'color-scheme',
      ) as DBusVariant;
    } on Exception {
      result = null;
    }

    if (result == null) return null;

    return (result.value as DBusUint32).value;
  }

  Stream<int> get themePreferenceStream => _settingsPortal.settingChanged
      .where((event) => event.key == 'color-scheme')
      .where((event) => event.value.runtimeType == DBusUint32)
      .map((event) => (event.value as DBusUint32).value);
}
