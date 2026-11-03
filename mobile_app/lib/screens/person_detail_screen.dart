import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/person.dart';
import '../services/api_service.dart';
import 'person_form_screen.dart';

/// 2. Kişi Detay Sayfası (ID Bazlı Veri & Aksiyon):
/// Seçilen kişinin ID'si ile GET /api/persons/{id} ucundan detayları çeker.
class PersonDetailScreen extends StatefulWidget {
  final int personId;

  const PersonDetailScreen({super.key, required this.personId});

  @override
  State<PersonDetailScreen> createState() => _PersonDetailScreenState();
}

class _PersonDetailScreenState extends State<PersonDetailScreen> {
  final ApiService _apiService = ApiService();
  late Future<Person> _personFuture;

  @override
  void initState() {
    super.initState();
    _loadPerson();
  }

  // ID bazlı kişi detaylarını sunucudan çeker (GET /api/persons/{id})
  void _loadPerson() {
    setState(() {
      _personFuture = _apiService.getPersonById(widget.personId);
    });
  }

  // Sil butonuna tıklandığında onay diyaloğu açar ve DELETE isteği yollar
  Future<void> _confirmAndDelete(Person person) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Kişiyi Sil',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          '${person.fullName} isimli kişiyi silmek istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          // Silme onayı butonu (Canlı müdahalede backgroundColor rengi değiştirilebilir)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(88, 42),
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _apiService.deletePerson(person.id!);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Person>(
      future: _personFuture,
      builder: (context, snapshot) {
        final person = snapshot.data;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Kişi Detay Bilgileri'),
          ),
          body: _buildBody(snapshot),
          // En Altta Sabit Aksiyon Butonları: DÜZENLE ve KİŞİYİ SİL
          bottomNavigationBar: person == null
              ? null
              : Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PersonFormScreen(person: person),
                                ),
                              );
                              _loadPerson();
                            },
                            icon: const Icon(Icons.edit_outlined, size: 19),
                            label: const Text('DÜZENLE'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFDC2626),
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => _confirmAndDelete(person),
                            icon: const Icon(Icons.delete_outline, size: 19),
                            label: const Text('KİŞİYİ SİL'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildBody(AsyncSnapshot<Person> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return Center(child: Text('Hata: ${snapshot.error}'));
    }

    final person = snapshot.data!;
    final hasPhoto = person.photoUrl.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Üst Panel: Büyük profil fotoğrafı, merkezde Ad-Soyad ve Departman unvanı
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundColor: const Color(0xFFEFF6FF),
                    backgroundImage:
                        hasPhoto ? NetworkImage(person.photoUrl) : null,
                    child: hasPhoto
                        ? null
                        : Text(
                            person.fullName[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    person.fullName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      person.department,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Alt Panel: Kartlar/satırlar halinde detaylar ve iletişim aksiyonları
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _buildDetailRow(
                  icon: Icons.location_on_outlined,
                  label: 'Doğum Yeri',
                  value: person.birthPlace,
                ),
                const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
                _buildDetailRow(
                  icon: Icons.cake_outlined,
                  label: 'Doğum Tarihi',
                  value: person.birthDate,
                ),
                const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
                // Tıklanabilir E-posta satırı -> mailto: niyetini tetikler
                _buildDetailRow(
                  icon: Icons.email_outlined,
                  label: 'E-Posta',
                  value: person.email,
                  onTap: () => launchUrl(Uri.parse('mailto:${person.email}')),
                ),
                const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
                // Tıklanabilir Telefon satırı -> tel: niyetini tetikler
                _buildDetailRow(
                  icon: Icons.phone_outlined,
                  label: 'Telefon',
                  value: person.phone,
                  onTap: () => launchUrl(Uri.parse('tel:${person.phone}')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    final isClickable = onTap != null;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(
        icon,
        color: isClickable ? const Color(0xFF2563EB) : const Color(0xFF64748B),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF64748B),
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color:
                isClickable ? const Color(0xFF2563EB) : const Color(0xFF0F172A),
          ),
        ),
      ),
      trailing: isClickable
          ? const Icon(
              Icons.open_in_new_rounded,
              size: 18,
              color: Color(0xFF2563EB),
            )
          : null,
    );
  }
}
