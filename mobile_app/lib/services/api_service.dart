import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/person.dart';

/// Backend REST API (/api/persons) ile asenkron HTTP haberleşmesini yöneten sınıf.
class ApiService {
  // Android emülatörde bilgisayarın localhost'una 10.0.2.2 ile erişilir.
  static const String baseUrl = 'http://10.0.2.2:8000/api/persons';

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  // 1. GET /api/persons -> Tüm kişileri dizi (List<Person>) olarak getirir.
  Future<List<Person>> getPersons() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((item) => Person.fromJson(item)).toList();
    }
    throw Exception('Kişi listesi alınamadı');
  }

  // 2. GET /api/persons/{id} -> Seçilen kişinin detaylarını getirir.
  Future<Person> getPersonById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(utf8.decode(response.bodyBytes));
      return Person.fromJson(data);
    }
    throw Exception('Kişi detayları alınamadı');
  }

  // 3. POST /api/persons -> Yeni kişi kaydı oluşturur.
  Future<void> createPerson(Person person) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: _headers,
      body: jsonEncode(person.toJson()),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Kişi eklenemedi');
    }
  }

  // 4. PUT /api/persons/{id} -> Kişi bilgilerini günceller.
  Future<void> updatePerson(int id, Person person) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: _headers,
      body: jsonEncode(person.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Kişi güncellenemedi');
    }
  }

  // 5. DELETE /api/persons/{id} -> İlgili kaydı kalıcı olarak siler.
  Future<void> deletePerson(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Kişi silinemedi');
    }
  }
}
