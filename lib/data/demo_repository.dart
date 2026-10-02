import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

abstract interface class DemoRepository {
  Future<Map<String, dynamic>?> read();
  Future<void> write(Map<String, dynamic> data);
  Future<void> clear();
}

class PreferencesDemoRepository implements DemoRepository {
  static const _key = 'job_matcher_demo_v1';
  @override
  Future<Map<String, dynamic>?> read() async {
    final raw = (await SharedPreferences.getInstance()).getString(_key);
    return raw == null ? null : jsonDecode(raw) as Map<String, dynamic>;
  }

  @override
  Future<void> write(Map<String, dynamic> data) async =>
      (await SharedPreferences.getInstance()).setString(_key, jsonEncode(data));
  @override
  Future<void> clear() async =>
      (await SharedPreferences.getInstance()).remove(_key);
}
