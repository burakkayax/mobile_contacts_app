import 'package:flutter/material.dart';
import '../models/person.dart';
import '../services/api_service.dart';
import 'person_detail_screen.dart';
import 'person_form_screen.dart';

/// 1. Kişi Listesi (Ana Sayfa):
/// API'deki /api/persons ucundan çekilen verileri ListView içinde listeler.
class PersonListScreen extends StatefulWidget {
  const PersonListScreen({super.key});

  @override
  State<PersonListScreen> createState() => _PersonListScreenState();
}

class _PersonListScreenState extends State<PersonListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Person>> _personsFuture;

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  // Sunucudan kişi listesini yeniden çeker (GET /api/persons)
  void _refreshList() {
    setState(() {
      _personsFuture = _apiService.getPersons();
    });
  }

  // Fiziksel telefonda test ederken sunucu IP adresini değiştirmeyi sağlar
  void _editApiUrl() {
    final ctrl = TextEditingController(text: ApiService.baseUrl);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sunucu Adresi'),
        content: TextField(controller: ctrl),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(88, 42),
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              ApiService.baseUrl = ctrl.text.trim();
              Navigator.pop(context);
              _refreshList();
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rehber / Kişi Listesi'),
        actions: [
          IconButton(
            onPressed: _editApiUrl,
            icon: const Icon(Icons.settings_outlined),
          ),
          IconButton(
            onPressed: _refreshList,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: FutureBuilder<List<Person>>(
        future: _personsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          final persons = snapshot.data ?? [];
          if (persons.isEmpty) {
            return const Center(child: Text('Kayıtlı kişi bulunamadı.'));
          }

          // Aşağı çekerek yenilenebilir Dinamik Liste (ListView)
          return RefreshIndicator(
            onRefresh: () async => _refreshList(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              itemCount: persons.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final person = persons[index];
                final hasPhoto = person.photoUrl.isNotEmpty;

                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    // Solda dairesel profil fotoğrafı (boşsa baş harf)
                    leading: CircleAvatar(
                      radius: 26,
                      backgroundColor: const Color(0xFFEFF6FF),
                      backgroundImage:
                          hasPhoto ? NetworkImage(person.photoUrl) : null,
                      child: hasPhoto
                          ? null
                          : Text(
                              person.fullName[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                    ),
                    // Kalın yazı tipiyle Ad-Soyad
                    title: Text(
                      person.fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    // Altında Departman bilgisi (Canlı müdahalede person.phone yapılabilir)
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        person.department,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF94A3B8),
                    ),
                    // Satıra tıklandığında seçilen kişinin ID'si ile Detay Sayfası açılır
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PersonDetailScreen(personId: person.id!),
                        ),
                      );
                      _refreshList();
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      // Sağ alt köşede sabit + simgeli Floating Action Button (FAB)
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PersonFormScreen(),
            ),
          );
          _refreshList();
        },
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}
