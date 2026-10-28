import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/person.dart';
import '../services/api_service.dart';
import '../widgets/person_avatar.dart';
import 'person_form_screen.dart';

/// 2. Kişi Detay Sayfası (ID Bazlı Veri & Aksiyon):
/// Seçilen kişinin benzersiz ID'si ile GET /api/persons/{id} ucundan detayları çeker,
/// iletişim niyetlerini (tel/mailto) tetikler ve en altta sabit Düzenle/Sil butonlarını sunar.
class PersonDetailScreen extends StatefulWidget {
  final int personId;

  const PersonDetailScreen({super.key, required this.personId});

  @override
  State<PersonDetailScreen> createState() => _PersonDetailScreenState();
}

class _PersonDetailScreenState extends State<PersonDetailScreen> {
  final ApiService _apiService = ApiService();
  late Future<Person> _personFuture;
  bool _hasChanges = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _loadPerson();
  }

  /// ID bazlı kişi detaylarını sunucudan çeker (GET /api/persons/{id}).
  void _loadPerson() {
    setState(() {
      _personFuture = _apiService.getPersonById(widget.personId);
    });
  }

  /// E-posta satırına tıklandığında sistemin posta gönderme niyetini (mailto:) tetikler.
  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email.trim(),
    );
    final launched = await launchUrl(emailUri);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('E-posta uygulaması açılamadı: $email')),
      );
    }
  }

  /// Telefon satırına tıklandığında sistemin arama niyetini (tel:) tetikler.
  Future<void> _launchPhone(String phone) async {
    final cleanedPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: cleanedPhone,
    );
    final launched = await launchUrl(phoneUri);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Telefon arama ekranı açılamadı: $phone')),
      );
    }
  }

  /// Düzenle butonuna tıklandığında mevcut kişi bilgileriyle güncelleme ekranını açar.
  Future<void> _openEditScreen(Person person) async {
    final updated = await Navigator.push<Person>(
      context,
      MaterialPageRoute(
        builder: (context) => PersonFormScreen(person: person),
      ),
    );

    if (updated != null && mounted) {
      _hasChanges = true;
      _loadPerson();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kişi bilgileri güncellendi')),
      );
    }
  }

  /// Sil butonuna tıklandığında kullanıcıdan onay diyaloğu alır ve DELETE /api/persons/{id} isteği yollar.
  Future<void> _confirmAndDelete(Person person) async {
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.delete_outline_rounded,
          color: colorScheme.error,
          size: 36,
        ),
        title: const Text('Kişiyi Sil'),
        content: Text(
          '${person.fullName} isimli kişiyi kalıcı olarak silmek istediğinize emin misiniz?',
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('İptal'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                // Silme onayı uyarısının aksiyon butonu (Canlı müdahalede backgroundColor değiştirilebilir)
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    foregroundColor: colorScheme.onError,
                  ),
                  child: const Text('Sil'),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      await _apiService.deletePerson(person.id!);
      if (!mounted) return;
      // Silme başarılı olduğunda listeye geri döner ve listenin yenilenmesini tetikler
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isDeleting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Silme işlemi başarısız: $e'),
          backgroundColor: colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Geri tuşuna basıldığında güncelleme yapıldıysa ana listenin yenilenmesi için _hasChanges döndürülür
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pop(context, _hasChanges);
        }
      },
      child: FutureBuilder<Person>(
        future: _personFuture,
        builder: (context, snapshot) {
          final person = snapshot.data;

          return Scaffold(
            appBar: AppBar(
              titleSpacing: 4,
              title: const Text('Kişi Detay Bilgileri'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, size: 22),
                onPressed: () => Navigator.pop(context, _hasChanges),
              ),
            ),
            body: _buildBody(colorScheme, textTheme, snapshot),
            // En Altta Sabit Aksiyon Butonları: DÜZENLE ve KİŞİYİ SİL (Şekil 1 Wireframe uyumlu)
            bottomNavigationBar: person == null
                ? null
                : SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 52,
                              child: FilledButton.icon(
                                onPressed: _isDeleting
                                    ? null
                                    : () => _openEditScreen(person),
                                icon: const Icon(Icons.edit_outlined, size: 19),
                                label: const Text('DÜZENLE'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 52,
                              child: FilledButton.icon(
                                onPressed: _isDeleting
                                    ? null
                                    : () => _confirmAndDelete(person),
                                style: FilledButton.styleFrom(
                                  backgroundColor: colorScheme.error,
                                  foregroundColor: colorScheme.onError,
                                ),
                                icon: _isDeleting
                                    ? SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: colorScheme.onError,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.delete_outline_rounded,
                                        size: 19,
                                      ),
                                label: const Text('KİŞİYİ SİL'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildBody(
    ColorScheme colorScheme,
    TextTheme textTheme,
    AsyncSnapshot<Person> snapshot,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 44,
                    color: colorScheme.error,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Veri yüklenemedi:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _loadPerson,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final person = snapshot.data!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Üst Panel: Büyük profil fotoğrafı, merkezde Ad-Soyad ve Departman unvanı
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                children: [
                  PersonAvatar(
                    photoUrl: person.photoUrl,
                    fullName: person.fullName,
                    radius: 48,
                    heroTag: person.id != null
                        ? 'person-avatar-${person.id}'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    person.fullName,
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      person.department,
                      textAlign: TextAlign.center,
                      style: textTheme.titleSmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Alt Panel: Doğum Yeri, Doğum Tarihi, E-Posta (tıklanabilir) ve Telefon (tıklanabilir)
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _buildDetailTile(
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  icon: Icons.location_on_outlined,
                  label: 'Doğum Yeri',
                  value: person.birthPlace,
                ),
                Divider(
                  height: 1,
                  indent: 72,
                  endIndent: 16,
                  color: colorScheme.outlineVariant,
                ),
                _buildDetailTile(
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  icon: Icons.cake_outlined,
                  label: 'Doğum Tarihi',
                  value: person.formattedBirthDate,
                ),
                Divider(
                  height: 1,
                  indent: 72,
                  endIndent: 16,
                  color: colorScheme.outlineVariant,
                ),
                _buildDetailTile(
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  icon: Icons.email_outlined,
                  label: 'E-Posta',
                  value: person.email,
                  onTap: () => _launchEmail(person.email),
                ),
                Divider(
                  height: 1,
                  indent: 72,
                  endIndent: 16,
                  color: colorScheme.outlineVariant,
                ),
                _buildDetailTile(
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  icon: Icons.phone_outlined,
                  label: 'Telefon',
                  value: person.phone,
                  onTap: () => _launchPhone(person.phone),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTile({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    final isAction = onTap != null;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isAction
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isAction
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isAction
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            if (isAction) ...[
              const SizedBox(width: 12),
              Icon(
                Icons.arrow_outward_rounded,
                size: 18,
                color: colorScheme.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
