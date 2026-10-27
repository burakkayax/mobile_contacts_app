import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/person.dart';

class ApiService {
  static String _customBaseUrl = const String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_customBaseUrl.isNotEmpty) {
      return _customBaseUrl;
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api/persons';
    }
    return 'http://127.0.0.1:8000/api/persons';
  }

  static void setBaseUrl(String url) {
    _customBaseUrl = url.trim().replaceAll(RegExp(r'/+$'), '');
  }

  static const Duration _timeout = Duration(seconds: 10);

  static Map<String, String> get _headers => const {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      };

  Future<List<Person>> getPersons() async {
    final response = await http
        .get(Uri.parse(baseUrl), headers: _headers)
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final List<dynamic> decoded = jsonDecode(utf8.decode(response.bodyBytes));
      return decoded
          .map((item) => Person.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Kişi listesi alınamadı (HTTP ${response.statusCode})');
  }

  Future<Person> getPersonById(int id) async {
    final response = await http
        .get(
          Uri.parse('$baseUrl/$id'),
          headers: _headers,
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded =
          jsonDecode(utf8.decode(response.bodyBytes));
      return Person.fromJson(decoded);
    }
    throw Exception('Kişi detayları alınamadı (HTTP ${response.statusCode})');
  }

  Future<Person> createPerson(Person person) async {
    final response = await http
        .post(
          Uri.parse(baseUrl),
          headers: _headers,
          body: jsonEncode(person.toJson()),
        )
        .timeout(_timeout);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> decoded =
          jsonDecode(utf8.decode(response.bodyBytes));
      return Person.fromJson(decoded);
    }
    throw Exception('Yeni kişi kaydedilemedi (HTTP ${response.statusCode})');
  }

  Future<Person> updatePerson(int id, Person person) async {
    final response = await http
        .put(
          Uri.parse('$baseUrl/$id'),
          headers: _headers,
          body: jsonEncode(person.toJson()),
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded =
          jsonDecode(utf8.decode(response.bodyBytes));
      return Person.fromJson(decoded);
    }
    throw Exception('Kişi güncellenemedi (HTTP ${response.statusCode})');
  }

  Future<void> deletePerson(int id) async {
    final response = await http
        .delete(
          Uri.parse('$baseUrl/$id'),
          headers: _headers,
        )
        .timeout(_timeout);

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Kişi silinemedi (HTTP ${response.statusCode})');
    }
  }
}
