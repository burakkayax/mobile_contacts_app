import 'package:flutter/material.dart';
import '../models/person.dart';
import '../services/api_service.dart';

/// Yeni Kişi Kayıt (POST /api/persons) ve Güncelleme (PUT /api/persons/{id}) Ekranı.
class PersonFormScreen extends StatefulWidget {
  final Person? person;

  const PersonFormScreen({super.key, this.person});

  @override
  State<PersonFormScreen> createState() => _PersonFormScreenState();
}

class _PersonFormScreenState extends State<PersonFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  late final _fullNameCtrl = TextEditingController(text: widget.person?.fullName);
  late final _deptCtrl = TextEditingController(text: widget.person?.department);
  late final _placeCtrl = TextEditingController(text: widget.person?.birthPlace);
  late final _dateCtrl = TextEditingController(text: widget.person?.birthDate);
  late final _emailCtrl = TextEditingController(text: widget.person?.email);
  late final _phoneCtrl = TextEditingController(text: widget.person?.phone);
  late final _photoCtrl = TextEditingController(text: widget.person?.photoUrl);

  bool get isEditing => widget.person != null;

  // Form verilerini doğrular; düzenleme modundaysa PUT, yeni kayıtsa POST gönderir
  Future<void> _savePerson() async {
    if (!_formKey.currentState!.validate()) return;

    final personData = Person(
      id: widget.person?.id,
      fullName: _fullNameCtrl.text.trim(),
      department: _deptCtrl.text.trim(),
      birthPlace: _placeCtrl.text.trim(),
      birthDate: _dateCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      photoUrl: _photoCtrl.text.trim(),
    );

    try {
      if (isEditing) {
        await _apiService.updatePerson(widget.person!.id!, personData);
      } else {
        await _apiService.createPerson(personData);
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Kişiyi Düzenle' : 'Yeni Kişi Ekle'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_fullNameCtrl, 'Ad Soyad', Icons.person_outline),
              _buildTextField(_deptCtrl, 'Departman', Icons.work_outline),
              _buildTextField(_placeCtrl, 'Doğum Yeri', Icons.location_on_outlined),
              _buildTextField(_dateCtrl, 'Doğum Tarihi (YYYY-AA-GG)', Icons.cake_outlined),
              _buildTextField(_emailCtrl, 'E-Posta', Icons.email_outlined),
              _buildTextField(_phoneCtrl, 'Telefon', Icons.phone_outlined),
              _buildTextField(
                _photoCtrl,
                'Fotoğraf URL (İsteğe Bağlı)',
                Icons.image_outlined,
                isRequired: false,
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _savePerson,
                  child: Text(isEditing ? 'DEĞİŞİKLİKLERİ KAYDET' : 'KAYDET'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isRequired = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20, color: const Color(0xFF64748B)),
        ),
        validator: (value) {
          if (isRequired && (value == null || value.trim().isEmpty)) {
            return '$label alanı zorunludur';
          }
          return null;
        },
      ),
    );
  }
}
