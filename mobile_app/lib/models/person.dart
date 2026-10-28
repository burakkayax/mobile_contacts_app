/// Sunucudan (REST API) gelen JSON verilerini yerel Dart nesnesine bağlayan model sınıfı.
class Person {
  final int? id;
  final String fullName;
  final String department;
  final String photoUrl;
  final String birthPlace;
  final String birthDate;
  final String email;
  final String phone;

  const Person({
    this.id,
    required this.fullName,
    required this.department,
    required this.photoUrl,
    required this.birthPlace,
    required this.birthDate,
    required this.email,
    required this.phone,
  });

  /// API'den gelen JSON haritasını (Map) Person nesnesine dönüştürür (Deserialization).
  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] as int?,
      fullName: (json['fullName'] ?? '') as String,
      department: (json['department'] ?? '') as String,
      photoUrl: (json['photoUrl'] ?? '') as String,
      birthPlace: (json['birthPlace'] ?? '') as String,
      birthDate: (json['birthDate'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      phone: (json['phone'] ?? '') as String,
    );
  }

  /// Person nesnesini POST ve PUT isteklerinde gönderilecek JSON haritasına dönüştürür (Serialization).
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'fullName': fullName,
      'department': department,
      'photoUrl': photoUrl,
      'birthPlace': birthPlace,
      'birthDate': birthDate,
      'email': email,
      'phone': phone,
    };
  }

  /// YYYY-MM-DD formatındaki tarihi ekranda GG.AA.YYYY (Örn: 12.04.1994) olarak gösterir.
  String get formattedBirthDate {
    final parts = birthDate.split('-');
    if (parts.length == 3) {
      return '${parts[2]}.${parts[1]}.${parts[0]}';
    }
    return birthDate;
  }
}
