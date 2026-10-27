import 'package:flutter/material.dart';
import '../models/person.dart';
import '../services/api_service.dart';

class PersonFormScreen extends StatefulWidget {
  final Person? person;

  const PersonFormScreen({super.key, this.person});

  bool get isEditing => person != null;

  @override
  State<PersonFormScreen> createState() => _PersonFormScreenState();
}

class _PersonFormScreenState extends State<PersonFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  late final TextEditingController _fullNameController;
  late final TextEditingController _departmentController;
  late final TextEditingController _photoUrlController;
  late final TextEditingController _birthPlaceController;
  late final TextEditingController _birthDateController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final p = widget.person;
    _fullNameController = TextEditingController(text: p?.fullName ?? '');
    _departmentController = TextEditingController(text: p?.department ?? '');
    _photoUrlController = TextEditingController(text: p?.photoUrl ?? '');
    _birthPlaceController = TextEditingController(text: p?.birthPlace ?? '');
    _birthDateController = TextEditingController(
      text: p?.birthDate ?? '1995-01-01',
    );
    _emailController = TextEditingController(text: p?.email ?? '');
    _phoneController = TextEditingController(text: p?.phone ?? '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _departmentController.dispose();
    _photoUrlController.dispose();
    _birthPlaceController.dispose();
    _birthDateController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final parsed = DateTime.tryParse(_birthDateController.text.trim());
    final initialDate = parsed ?? DateTime(1995, 1, 1);

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );

    if (selected != null) {
      final year = selected.year.toString().padLeft(4, '0');
      final month = selected.month.toString().padLeft(2, '0');
      final day = selected.day.toString().padLeft(2, '0');
      setState(() {
        _birthDateController.text = '$year-$month-$day';
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final payload = Person(
      id: widget.person?.id,
      fullName: _fullNameController.text.trim(),
      department: _departmentController.text.trim(),
      photoUrl: _photoUrlController.text.trim(),
      birthPlace: _birthPlaceController.text.trim(),
      birthDate: _birthDateController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    try {
      if (widget.isEditing) {
        final updated = await _apiService.updatePerson(
          widget.person!.id!,
          payload,
        );
        if (!mounted) return;
        Navigator.pop(context, updated);
      } else {
        final created = await _apiService.createPerson(payload);
        if (!mounted) return;
        Navigator.pop(context, created);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('İşlem başarısız: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isEditing ? 'Kişi Bilgilerini Düzenle' : 'Yeni Kişi Kaydı',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                textTheme: textTheme,
                controller: _fullNameController,
                label: 'Ad Soyad',
                hint: 'Örn: Ahmet Yılmaz',
                icon: Icons.person_outline_rounded,
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Ad Soyad zorunludur'
                    : null,
              ),
              const SizedBox(height: 14),
              _buildTextField(
                textTheme: textTheme,
                controller: _departmentController,
                label: 'Departman / Unvan',
                hint: 'Örn: Yazılım Geliştirme',
                icon: Icons.work_outline_rounded,
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Departman zorunludur'
                    : null,
              ),
              const SizedBox(height: 14),
              _buildTextField(
                textTheme: textTheme,
                controller: _birthPlaceController,
                label: 'Doğum Yeri',
                hint: 'Örn: Adana',
                icon: Icons.location_on_outlined,
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Doğum yeri zorunludur'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _birthDateController,
                readOnly: true,
                style: textTheme.bodyLarge,
                onTap: _pickBirthDate,
                decoration: InputDecoration(
                  labelText: 'Doğum Tarihi (YYYY-AA-GG)',
                  prefixIcon: const Icon(Icons.cake_outlined, size: 20),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today_rounded, size: 20),
                    onPressed: _pickBirthDate,
                  ),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Doğum tarihi zorunludur'
                    : null,
              ),
              const SizedBox(height: 14),
              _buildTextField(
                textTheme: textTheme,
                controller: _emailController,
                label: 'E-Posta Adresi',
                hint: 'Örn: ahmet.yilmaz@sirket.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'E-posta zorunludur';
                  }
                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(val.trim())) {
                    return 'Geçerli bir e-posta giriniz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _buildTextField(
                textTheme: textTheme,
                controller: _phoneController,
                label: 'Telefon Numarası',
                hint: 'Örn: +905550123456',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Telefon numarası zorunludur'
                    : null,
              ),
              const SizedBox(height: 14),
              _buildTextField(
                textTheme: textTheme,
                controller: _photoUrlController,
                label: 'Profil Fotoğrafı URL (İsteğe Bağlı)',
                hint: 'https://randomuser.me/api/portraits/men/32.jpg',
                icon: Icons.image_outlined,
                keyboardType: TextInputType.url,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: _isSubmitting ? null : _submitForm,
              icon: _isSubmitting
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : Icon(
                      widget.isEditing
                          ? Icons.check_rounded
                          : Icons.person_add_alt_1_rounded,
                      size: 20,
                    ),
              label: Text(
                widget.isEditing ? 'DEĞİŞİKLİKLERİ KAYDET' : 'KİŞİYİ KAYDET',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextTheme textTheme,
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: textTheme.bodyLarge,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
      ),
    );
  }
}
