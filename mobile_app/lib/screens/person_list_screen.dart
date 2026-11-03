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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rehber / Kişi Listesi'),
        actions: [
          IconButton(
            onPressed: _refreshList,
            icon: const Icon(Icons.refresh),
          ),
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

          // Dinamik Liste (ListView)
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: persons.length,
            itemBuilder: (context, index) {
              final person = persons[index];
              final hasPhoto = person.photoUrl.isNotEmpty;

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  // Solda dairesel profil fotoğrafı (ağ resmi)
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundImage:
                        hasPhoto ? NetworkImage(person.photoUrl) : null,
                    onBackgroundImageError: hasPhoto ? (_, _) {} : null,
                    child: hasPhoto ? null : const Icon(Icons.person),
                  ),
                  // Kalın yazı tipiyle Ad-Soyad
                  title: Text(
                    person.fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  // Altında Departman bilgisi (Canlı müdahalede person.phone yapılabilir)
                  subtitle: Text(person.department),
                  trailing: const Icon(Icons.chevron_right),
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
          );
        },
      ),
      // Sağ alt köşede sabit + simgeli Floating Action Button (FAB)
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PersonFormScreen(),
            ),
          );
          _refreshList();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
