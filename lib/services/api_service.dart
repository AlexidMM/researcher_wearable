import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../models/app_notification.dart';
import '../models/publication.dart';

class ApiService {
  ApiService({String? baseUrl}) : baseUrl = baseUrl ?? ApiConfig.baseUrl;

  static const tokenKey = 'access_token';
  static const _timeout = Duration(seconds: 15);

  final String baseUrl;
  String? _cachedToken;

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
    if (_cachedToken != null && _cachedToken!.isNotEmpty) {
      return _cachedToken;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      _cachedToken = prefs.getString(tokenKey);
    } catch (_) {
      // En algunos entornos de escritorio prefs puede fallar al inicio.
    }

    return _cachedToken;
  }

  Future<void> saveToken(String token) async {
    _cachedToken = token;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(tokenKey, token);
    } catch (_) {}
  }

  Future<void> clearToken() async {
    _cachedToken = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(tokenKey);
    } catch (_) {}
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/auth/login'),
          headers: await _headers(withAuth: false),
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(_timeout);

    final data = _decodeResponse(response);

    if (response.statusCode >= 400) {
      throw Exception(_messageFrom(data) ?? 'Error al iniciar sesión (${response.statusCode})');
    }

    final token = data['access_token'] as String?;
    if (token == null) {
      throw Exception('La API no devolvió un token válido');
    }

    await saveToken(token);
    return data as Map<String, dynamic>;
  }

  Future<List<Publication>> fetchMyPublications() async {
    final response = await http
        .get(
          Uri.parse('$baseUrl/publications/mine'),
          headers: await _headers(),
        )
        .timeout(_timeout);

    final data = _decodeResponse(response);

    if (response.statusCode >= 400) {
      throw Exception(_messageFrom(data) ?? 'Error al cargar publicaciones (${response.statusCode})');
    }

    if (data is! List) {
      throw Exception('Respuesta inesperada de /publications/mine');
    }

    return data
        .map((item) => Publication.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<AppNotification>> fetchMyNotifications() async {
    final response = await http
        .get(
          Uri.parse('$baseUrl/notifications/mine'),
          headers: await _headers(),
        )
        .timeout(_timeout);

    final data = _decodeResponse(response);

    if (response.statusCode >= 400) {
      throw Exception(_messageFrom(data) ?? 'Error al cargar notificaciones (${response.statusCode})');
    }

    if (data is! List) {
      return [];
    }

    return data
        .map((item) => AppNotification.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  dynamic _decodeResponse(http.Response response) {
    if (response.body.isEmpty) return null;

    try {
      return jsonDecode(response.body);
    } catch (_) {
      throw Exception('La API respondió con un formato no válido');
    }
  }

  String? _messageFrom(dynamic data) {
    if (data is! Map) return null;
    final message = data['message'];
    if (message is List) return message.join(', ');
    if (message != null) return message.toString();
    return null;
  }
}
