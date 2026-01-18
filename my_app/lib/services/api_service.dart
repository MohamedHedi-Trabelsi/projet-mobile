import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Android Emulator:
  static const String baseUrl = 'http://10.0.2.2:8000';
  // iOS Simulator: 'http://127.0.0.1:8000'
  // Real phone: 'http://IP_DE_TON_PC:8000'

  static dynamic _decode(http.Response res) {
    try {
      return jsonDecode(res.body);
    } catch (_) {
      return {'detail': 'Réponse serveur invalide'};
    }
  }

  // ---------- AUTH ----------
  static Future<Map<String, dynamic>> signup({
    required String nom,
    required String prenom,
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'password': password,
      }),
    );

    final data = _decode(res);
    if (res.statusCode == 200) return Map<String, dynamic>.from(data);
    throw Exception(data['detail'] ?? 'Erreur signup');
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = _decode(res);
    if (res.statusCode == 200) return Map<String, dynamic>.from(data);
    throw Exception(data['detail'] ?? 'Erreur login');
  }

  // ---------- CONTACTS ----------
  static Future<List<dynamic>> getContacts(int userId) async {
    final res = await http.get(Uri.parse('$baseUrl/users/$userId/contacts'));
    final data = _decode(res);

    if (res.statusCode == 200 && data is List) return data;
    throw Exception((data is Map ? data['detail'] : null) ?? 'Erreur getContacts');
  }

  static Future<void> addContact({
    required int userId,
    required String nom,
    required String email,
    required String telephone,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/users/$userId/contacts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nom': nom, 'email': email, 'telephone': telephone}),
    );

    final data = _decode(res);
    if (res.statusCode == 200) return;
    throw Exception((data is Map ? data['detail'] : null) ?? 'Erreur addContact');
  }

  static Future<void> deleteContact(int contactId) async {
    final res = await http.delete(Uri.parse('$baseUrl/contacts/$contactId'));
    final data = _decode(res);

    if (res.statusCode == 200) return;
    throw Exception((data is Map ? data['detail'] : null) ?? 'Erreur deleteContact');
  }
}
