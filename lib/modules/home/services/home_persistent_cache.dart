import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/home_cache_data.dart';

class HomePersistentCache {
  HomePersistentCache({SharedPreferences? preferences})
      : _preferences = preferences;

  static const String _cacheKey = 'fenix_home_dashboard_cache_v1';
  SharedPreferences? _preferences;

  Future<SharedPreferences> _prefs() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  Future<void> salvar(HomeCacheData data) async {
    final prefs = await _prefs();
    await prefs.setString(_cacheKey, jsonEncode(data.toMap()));
  }

  Future<HomeCacheData?> recuperar() async {
    final prefs = await _prefs();
    final conteudo = prefs.getString(_cacheKey);

    if (conteudo == null || conteudo.trim().isEmpty) return null;

    try {
      final decoded = jsonDecode(conteudo);
      if (decoded is! Map) {
        await limpar();
        return null;
      }
      return HomeCacheData.fromMap(Map<String, dynamic>.from(decoded));
    } catch (_) {
      await limpar();
      return null;
    }
  }

  Future<bool> possuiCache() async => await recuperar() != null;

  Future<void> limpar() async {
    final prefs = await _prefs();
    await prefs.remove(_cacheKey);
  }
}
