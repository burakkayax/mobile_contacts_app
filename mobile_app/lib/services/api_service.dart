import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/person.dart';

/// Backend REST API (/api/persons) ile asenkron HTTP haberleşmesini yöneten servis sınıfı.
class ApiService {
  static String _customBaseUrl = const String.fromEnvironment('API_BASE_URL');
  static const Duration _timeout = Duration(seconds: 10);

  /// Çalışılan platforma göre varsayılan API adresini belirler:
  /// - Android Emülatör: 10.0.2.2 (bilgisayarın localhost'una özel sanal köprü IP'si)
  /// - Masaüstü / iOS / Web: 127.0.0.1
  static String get baseUrl {
    if (_customBaseUrl.isNotEmpty) {
      return _customBaseUrl;
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api/persons';
    }
    return 'http://127.0.0.1:8000/api/persons';
  }

  /// Fiziksel cihaz testlerinde çalışma zamanında sunucu IP adresini değiştirmeyi sağlar.
  static void setBaseUrl(String url) {
    _customBaseUrl = url.trim().replaceAll(RegExp(r'/+$'), '');
  }

  static Map<String, String> get _headers => const {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      };

  /// 1. GET /api/persons -> Tüm kişileri dizi (`List<Person>`) olarak getirir.
  Future<List<Person>> getPersons() async {
    final response = await http
        .get(Uri.parse(baseUrl), headers: _headers)
        .timeout(_timeout);

    if (response.statusCode == 200) {
      // Türkçe karakterlerin bozulmaması için bodyBytes üzerinden UTF-8 çözümü yapılır
      final List<dynamic> decoded = jsonDecode(utf8.decode(response.bodyBytes));
      return decoded
          .map((item) => Person.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw Exception(_extractError(response, 'Kişi listesi alınamadı'));
  }

  /// 2. GET /api/persons/{id} -> Seçilen kişinin benzersiz ID'si ile tüm detaylarını getirir.
  Future<Person> getPersonById(int id) async {
    final response = await http
        .get(Uri.parse('$baseUrl/$id'), headers: _headers)
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded =
          jsonDecode(utf8.decode(response.bodyBytes));
      return Person.fromJson(decoded);
    }
    throw Exception(_extractError(response, 'Kişi detayları alınamadı'));
  }

  /// 3. POST /api/persons -> JSON gövdesi ile yeni kişi kaydı oluşturur.
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
    throw Exception(_extractError(response, 'Yeni kişi kaydedilemedi'));
  }

  /// 4. PUT /api/persons/{id} -> Belirtilen ID'li kişinin bilgilerini günceller.
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
    throw Exception(_extractError(response, 'Kişi güncellenemedi'));
  }

  /// 5. DELETE /api/persons/{id} -> İlgili kaydı veritabanından kalıcı olarak siler.
  Future<void> deletePerson(int id) async {
    final response = await http
        .delete(Uri.parse('$baseUrl/$id'), headers: _headers)
        .timeout(_timeout);

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception(_extractError(response, 'Kişi silinemedi'));
    }
  }

  /// Sunucudan dönen hata mesajını (özellikle HTTP 400 doğrulama hatalarını) ayrıştırır.
  String _extractError(http.Response response, String prefix) {
    try {
      final body = utf8.decode(response.bodyBytes).trim();
      if (body.isNotEmpty) {
        return '$prefix (HTTP ${response.statusCode}): $body';
      }
    } catch (_) {}
    return '$prefix (HTTP ${response.statusCode})';
  }
}
