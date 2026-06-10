import 'package:shared_preferences/shared_preferences.dart';

class SessionStorage {
  SessionStorage(this._prefs);

  final SharedPreferences _prefs;

  static const String _userIdKey = 'session.user_id';
  static const String _userNameKey = 'session.user_name';

  String? get userId => _prefs.getString(_userIdKey);
  String? get userName => _prefs.getString(_userNameKey);
  bool get hasSession => userId != null;

  Future<void> save({required String userId, required String userName}) async {
    await _prefs.setString(_userIdKey, userId);
    await _prefs.setString(_userNameKey, userName);
  }

  Future<void> clear() async {
    await _prefs.remove(_userIdKey);
    await _prefs.remove(_userNameKey);
  }
}
