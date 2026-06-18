import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../models/publication.dart';
import '../models/publication_stats.dart';

class ApiService {
  ApiService({String? baseUrl}) : baseUrl = baseUrl ?? ApiConfig.baseUrl;

  static const tokenKey = 'access_token';

  final String baseUrl;

  Future<Map<String, String>> _headers({bool withAuth = true}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (withAuth) {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: await _headers(withAuth: false),
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = _decodeResponse(response);

    if (response.statusCode >= 400) {
      throw Exception(data['message'] ?? 'Error al iniciar sesión');
    }

    final token = data['access_token'] as String?;
    if (token == null) {
      throw Exception('La API no devolvió un token válido');
    }

    await saveToken(token);
    return data;
  }

  Future<List<Publication>> fetchMyPublications() async {
    final response = await http.get(
      Uri.parse('$baseUrl/publications/mine'),
      headers: await _headers(),
    );

    final data = _decodeResponse(response);

    if (response.statusCode >= 400) {
      throw Exception(data['message'] ?? 'No se pudieron cargar las publicaciones');
    }

    return (data as List<dynamic>)
        .map((item) => Publication.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<PublicationStats> fetchMyStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/publications/stats/mine'),
      headers: await _headers(),
    );

    final data = _decodeResponse(response);

    if (response.statusCode >= 400) {
      throw Exception(data['message'] ?? 'No se pudieron cargar las estadísticas');
    }

    return PublicationStats.fromJson(data as Map<String, dynamic>);
  }

  Future<Publication> updatePublicationStatus(int id, bool status) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/publications/$id/status'),
      headers: await _headers(),
      body: jsonEncode({'status': status}),
    );

    final data = _decodeResponse(response);

    if (response.statusCode >= 400) {
      throw Exception(data['message'] ?? 'No se pudo actualizar el estado');
    }

    return Publication.fromJson(data as Map<String, dynamic>);
  }

  dynamic _decodeResponse(http.Response response) {
    if (response.body.isEmpty) {
      return null;
    }

    return jsonDecode(response.body);
  }
}
