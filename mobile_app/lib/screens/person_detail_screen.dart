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
        title: const Text('Kişiyi Sil'),
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
              backgroundColor: Colors.red,
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
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
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
                            icon: const Icon(Icons.edit),
                            label: const Text('DÜZENLE'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => _confirmAndDelete(person),
                            icon: const Icon(Icons.delete),
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
        children: [
          // Üstte büyük profil fotoğrafı, merkezde Ad-Soyad ve Departman unvanı
          CircleAvatar(
            radius: 48,
            backgroundImage: hasPhoto ? NetworkImage(person.photoUrl) : null,
            onBackgroundImageError: hasPhoto ? (_, _) {} : null,
            child: hasPhoto ? null : const Icon(Icons.person, size: 48),
          ),
          const SizedBox(height: 12),
          Text(
            person.fullName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            person.department,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // Alt panelde kartlar/satırlar halinde detaylar ve iletişim aksiyonları
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.location_on),
                  title: const Text('Doğum Yeri'),
                  subtitle: Text(person.birthPlace),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.cake),
                  title: const Text('Doğum Tarihi'),
                  subtitle: Text(person.birthDate),
                ),
                const Divider(height: 1),
                // Tıklanabilir E-posta satırı -> mailto: niyetini tetikler
                ListTile(
                  leading: const Icon(Icons.email, color: Colors.blue),
                  title: const Text('E-Posta'),
                  subtitle: Text(person.email),
                  onTap: () => launchUrl(Uri.parse('mailto:${person.email}')),
                ),
                const Divider(height: 1),
                // Tıklanabilir Telefon satırı -> tel: niyetini tetikler
                ListTile(
                  leading: const Icon(Icons.phone, color: Colors.blue),
                  title: const Text('Telefon'),
                  subtitle: Text(person.phone),
                  onTap: () => launchUrl(Uri.parse('tel:${person.phone}')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
