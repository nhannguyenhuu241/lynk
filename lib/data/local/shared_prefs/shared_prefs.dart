import 'package:shared_preferences/shared_preferences.dart';

import 'shared_prefs_key.dart';

class SharedPrefs {
  final SharedPreferences _prefs;

  SharedPrefs(this._prefs);

  // base
  dynamic get(String key) => _prefs.get(key);

  int getInt(String key, {int value = 0}) => _prefs.getInt(key) ?? value;

  String getString(String key, {String value = ""}) =>
      _prefs.getString(key) ?? value;

  double getDouble(String key, {double value = 0.0}) =>
      _prefs.getDouble(key) ?? value;

  List<String> getStringList(String key) => _prefs.getStringList(key) ?? [];

  bool getBool(String key, {bool value = false}) =>
      _prefs.getBool(key) ?? value;

  setString(String key, String? value, {String defaultValue = ""}) =>
      _prefs.setString(key, value ?? defaultValue);

  setDouble(String key, double? value, {double defaultValue = 0.0}) =>
      _prefs.setDouble(key, value ?? defaultValue);

  setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);

  setInt(String key, int? value, {int defaultValue = 0}) =>
      _prefs.setInt(key, value ?? defaultValue);

  setBool(String key, bool? value, {bool defaultValue = false}) =>
      _prefs.setBool(key, value ?? defaultValue);

  clearAll() {
    _prefs.clear();
  }

  dispose() {
    var key = [
      SharedPrefsKey.language,
      SharedPrefsKey.platform,
      SharedPrefsKey.is_init,
      SharedPrefsKey.font_size
    ];

    var value = <dynamic>[];

    for (var val in key) {
      value.add(get(val));
    }

    clearAll();

    for(var i = 0; i < key.length; i++){
      if(value[i] != null){
        if(value[i] is int) {
          setInt(key[i], value[i]);
        }
        else if(value[i] is String){
          setString(key[i], value[i]);
        }
        else if(value[i] is bool){
          setBool(key[i], value[i]);
        }
      }
    }
  }
}
