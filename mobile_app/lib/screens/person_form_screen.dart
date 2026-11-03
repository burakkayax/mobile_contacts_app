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

  late final TextEditingController _fullNameController;
  late final TextEditingController _departmentController;
  late final TextEditingController _birthPlaceController;
  late final TextEditingController _birthDateController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _photoUrlController;

  bool get isEditing => widget.person != null;

  @override
  void initState() {
    super.initState();
    final p = widget.person;
    _fullNameController = TextEditingController(text: p?.fullName ?? '');
    _departmentController = TextEditingController(text: p?.department ?? '');
    _birthPlaceController = TextEditingController(text: p?.birthPlace ?? '');
    _birthDateController = TextEditingController(text: p?.birthDate ?? '');
    _emailController = TextEditingController(text: p?.email ?? '');
    _phoneController = TextEditingController(text: p?.phone ?? '');
    _photoUrlController = TextEditingController(text: p?.photoUrl ?? '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _departmentController.dispose();
    _birthPlaceController.dispose();
    _birthDateController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  // Form verilerini doğrular; düzenleme modundaysa PUT, yeni kayıtsa POST gönderir
  Future<void> _savePerson() async {
    if (!_formKey.currentState!.validate()) return;

    final personData = Person(
      id: widget.person?.id,
      fullName: _fullNameController.text.trim(),
      department: _departmentController.text.trim(),
      birthPlace: _birthPlaceController.text.trim(),
      birthDate: _birthDateController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      photoUrl: _photoUrlController.text.trim(),
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
              _buildTextField(
                _fullNameController,
                'Ad Soyad',
                Icons.person_outline,
              ),
              _buildTextField(
                _departmentController,
                'Departman',
                Icons.work_outline,
              ),
              _buildTextField(
                _birthPlaceController,
                'Doğum Yeri',
                Icons.location_on_outlined,
              ),
              _buildTextField(
                _birthDateController,
                'Doğum Tarihi (YYYY-AA-GG)',
                Icons.cake_outlined,
              ),
              _buildTextField(
                _emailController,
                'E-Posta',
                Icons.email_outlined,
              ),
              _buildTextField(
                _phoneController,
                'Telefon',
                Icons.phone_outlined,
              ),
              _buildTextField(
                _photoUrlController,
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
