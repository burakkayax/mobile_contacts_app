/// Sunucudan gelen JSON verilerini yerel Dart nesnesine bağlayan model sınıfı.
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

  /// JSON verisini Person nesnesine dönüştürür (GET yanıtları için)
  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'],
      fullName: json['fullName'] ?? '',
      department: json['department'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      birthPlace: json['birthPlace'] ?? '',
      birthDate: json['birthDate'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  /// Person nesnesini JSON haritasına dönüştürür (POST ve PUT istekleri için)
  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'department': department,
      'photoUrl': photoUrl,
      'birthPlace': birthPlace,
      'birthDate': birthDate,
      'email': email,
      'phone': phone,
    };
  }
}
