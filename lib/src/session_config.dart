import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SessionConfig {
  /// [data] will be stored in the session, can be any map
  final Map<dynamic, dynamic> data;

  /// Immediately invalidates the sesion after [invalidateSessionForUserInactiviity] duration of user inactivity
  ///
  /// If null, never invalidates the session for user inactivity
  final Duration? invalidateSessionForUserInactiviity;

  ///  mmediately invalidates the sesion after [invalidateSessionForAppLostFocus] duration of app losing focus
  ///
  /// If null, never invalidates the session for app losing focus
  final Duration? invalidateSessionForAppLostFocus;

  SessionConfig({
    required this.data,
    this.invalidateSessionForUserInactiviity,
    this.invalidateSessionForAppLostFocus,
  }) {
    _initSharedPrefs().then((_) => _set(data));
  }

  /// acts as key for shared prefs
  final _key = "KEY";

  final _controller = StreamController<Map<dynamic, dynamic>?>();

  /// Stream yields Map if session is valid, else null
  Stream<Map<dynamic, dynamic>?> get stream => _controller.stream;

  SharedPreferences? _prefs;

  Future _initSharedPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Map<dynamic, dynamic>? _get() {
    return json.decode(_prefs!.get(_key) as String);
  }

  Future _set(value) async {
    await _initSharedPrefs();

    switch (value.runtimeType) {
      case String:
        _prefs!.setString(_key, value);
        break;
      case int:
        _prefs!.setInt(_key, value);
        break;
      case bool:
        _prefs!.setBool(_key, value);
        break;
      case double:
        _prefs!.setDouble(_key, value);
        break;
      case List:
        _prefs!.setStringList(_key, value);
        break;
      default:
        _prefs!.setString(_key, jsonEncode(value.toJson()));
    }
  }

  void _remove() {
    _prefs!.remove(_key);
  }

  /// Sends Map<dynamic,dynamic> data through the stream
  void pushSessionValidEvent() {
    _controller.sink.add(_get());
  }

  /// invalidate session and pass null through stream
  void pushSessionInvalidEvent() {
    _remove();
    _controller.sink.add(null);
  }
}
