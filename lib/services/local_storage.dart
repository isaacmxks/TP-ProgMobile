import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const _keyName = 'user_name';
  static const _keyEmail = 'user_email';
  static const _keyProvider = 'user_provider';

  // Sauvegarder les infos de l'utilisateur
  static Future<void> saveUser({
    required String name,
    required String email,
    required String provider,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyProvider, provider);
  }

  // Récupérer les infos de l'utilisateur
  static Future<Map<String, String>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_keyName) ?? 'Utilisateur',
      'email': prefs.getString(_keyEmail) ?? '',
      'provider': prefs.getString(_keyProvider) ?? '',
    };
  }

  // Déconnexion / supprimer les infos de l'utilisateur
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyName);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyProvider);
  }
}
