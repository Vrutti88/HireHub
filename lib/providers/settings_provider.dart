import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  SharedPreferences? _prefs;
  bool _stealthMode = false;
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _jobAlertsActive = true;
  ThemeMode _themeMode = ThemeMode.light;

  SettingsProvider() {
    _loadFromPrefs();
  }

  bool get stealthMode => _stealthMode;
  bool get pushNotifications => _pushNotifications;
  bool get emailNotifications => _emailNotifications;
  bool get jobAlertsActive => _jobAlertsActive;
  ThemeMode get themeMode => _themeMode;

  Future<void> _loadFromPrefs() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _stealthMode = _prefs?.getBool('stealthMode') ?? false;
      _pushNotifications = _prefs?.getBool('pushNotifications') ?? true;
      _emailNotifications = _prefs?.getBool('emailNotifications') ?? true;
      _jobAlertsActive = _prefs?.getBool('jobAlertsActive') ?? true;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> setStealthMode(bool val) async {
    _stealthMode = val;
    await _prefs?.setBool('stealthMode', val);
    notifyListeners();
  }

  Future<void> setPushNotifications(bool val) async {
    _pushNotifications = val;
    await _prefs?.setBool('pushNotifications', val);
    notifyListeners();
  }

  Future<void> setEmailNotifications(bool val) async {
    _emailNotifications = val;
    await _prefs?.setBool('emailNotifications', val);
    notifyListeners();
  }

  Future<void> setJobAlertsActive(bool val) async {
    _jobAlertsActive = val;
    await _prefs?.setBool('jobAlertsActive', val);
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}
