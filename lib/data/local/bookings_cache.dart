import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class BookingsCache {
  BookingsCache(this._prefs);

  final SharedPreferences _prefs;

  String _keyFor(String userId) => 'bookings_cache.v1.$userId';
  String _stampKeyFor(String userId) => 'bookings_cache.v1.$userId.stamp';

  Future<void> save(
    String userId,
    List<Map<String, dynamic>> raw,
  ) async {
    await _prefs.setString(_keyFor(userId), jsonEncode(raw));
    await _prefs.setString(
      _stampKeyFor(userId),
      DateTime.now().toIso8601String(),
    );
  }

  List<Map<String, dynamic>>? load(String userId) {
    final s = _prefs.getString(_keyFor(userId));
    if (s == null) return null;
    try {
      final list = jsonDecode(s) as List<dynamic>;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return null;
    }
  }

  DateTime? loadStamp(String userId) {
    final s = _prefs.getString(_stampKeyFor(userId));
    if (s == null) return null;
    return DateTime.tryParse(s);
  }

  Future<void> clear(String userId) async {
    await _prefs.remove(_keyFor(userId));
    await _prefs.remove(_stampKeyFor(userId));
  }
}
