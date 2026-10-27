import 'package:flutter/material.dart';
import '../models/person.dart';
import '../services/api_service.dart';
import '../widgets/person_avatar.dart';
import 'person_detail_screen.dart';
import 'person_form_screen.dart';

class PersonListScreen extends StatefulWidget {
  const PersonListScreen({super.key});

  @override
  State<PersonListScreen> createState() => _PersonListScreenState();
}

class _PersonListScreenState extends State<PersonListScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  late Future<List<Person>> _personsFuture;
  String _searchQuery = '';
  String _selectedDepartment = 'Tümü';

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshList() async {
    final future = _apiService.getPersons();
    setState(() {
      _personsFuture = future;
    });
    try {
      await future;
    } catch (_) {}
  }

  Future<void> _openCreateScreen() async {
    final created = await Navigator.push<Person>(
      context,
      MaterialPageRoute(
        builder: (context) => const PersonFormScreen(),
      ),
    );

    if (created != null && mounted) {
      _refreshList();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${created.fullName} rehbere eklendi')),
      );
    }
  }

  Future<void> _openDetailScreen(Person person) async {
    if (person.id == null) return;
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PersonDetailScreen(personId: person.id!),
      ),
    );

    if (changed == true && mounted) {
      _refreshList();
    }
  }

  Future<void> _showApiUrlDialog() async {
    final controller = TextEditingController(text: ApiService.baseUrl);
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('API Sunucu Adresi'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Uç Nokta URL',
            hintText: 'http://10.0.2.2:8000/api/persons',
            prefixIcon: Icon(Icons.link_rounded, size: 20),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () {
              ApiService.setBaseUrl(controller.text);
              Navigator.pop(context, true);
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );

    if (saved == true && mounted) {
      _refreshList();
    }
  }

  List<Person> _filterPersons(List<Person> persons, String activeDepartment) {
    final query = _searchQuery.trim().toLowerCase();
    return persons.where((person) {
      final matchesDepartment = activeDepartment == 'Tümü' ||
          person.department.trim().toLowerCase() ==
              activeDepartment.toLowerCase();
      final matchesQuery = query.isEmpty ||
          person.fullName.toLowerCase().contains(query) ||
          person.department.toLowerCase().contains(query);
      return matchesDepartment && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kişiler'),
        actions: [
          IconButton(
            onPressed: _showApiUrlDialog,
            tooltip: 'API Sunucu Adresi',
            style: IconButton.styleFrom(
              backgroundColor: colorScheme.surfaceContainerLow,
              fixedSize: const Size(40, 40),
            ),
            icon: Icon(
              Icons.tune_rounded,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _refreshList,
            tooltip: 'Yenile',
            style: IconButton.styleFrom(
              backgroundColor: colorScheme.surfaceContainerLow,
              fixedSize: const Size(40, 40),
            ),
            icon: Icon(
              Icons.refresh_rounded,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: FutureBuilder<List<Person>>(
        future: _personsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorState(
              colorScheme,
              textTheme,
              snapshot.error.toString(),
            );
          }

          final allPersons = snapshot.data ?? [];
          if (allPersons.isEmpty) {
            return _buildEmptyState(colorScheme, textTheme);
          }

          final departments = <String>{
            'Tümü',
            ...allPersons
                .map((p) => p.department.trim())
                .where((d) => d.isNotEmpty),
          }.toList();

          final activeDepartment = departments.contains(_selectedDepartment)
              ? _selectedDepartment
              : 'Tümü';

          final filteredPersons = _filterPersons(allPersons, activeDepartment);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                child: TextField(
                  controller: _searchController,
                  textAlignVertical: TextAlignVertical.center,
                  style: textTheme.bodyLarge,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Kişi veya departman ara...',
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    fillColor: colorScheme.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: departments.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final dept = departments[index];
                    final isSelected = dept == activeDepartment;
                    return ChoiceChip(
                      label: Text(dept),
                      selected: isSelected,
                      showCheckmark: false,
                      shape: const StadiumBorder(),
                      side: BorderSide.none,
                      backgroundColor: colorScheme.surfaceContainerLow,
                      selectedColor: colorScheme.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      labelStyle: TextStyle(
                        fontSize: 13.5,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurfaceVariant,
                      ),
                      onSelected: (_) {
                        setState(() => _selectedDepartment = dept);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filteredPersons.isEmpty
                    ? Center(
                        child: Text(
                          'Seçilen kriterlere uygun kişi bulunamadı.',
                          style: textTheme.bodyMedium,
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async => _refreshList(),
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                          itemCount: filteredPersons.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final person = filteredPersons[index];
                            return _buildPersonCard(
                              colorScheme,
                              textTheme,
                              person,
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateScreen,
        tooltip: 'Yeni Kişi Ekle',
        child: const Icon(Icons.add_rounded, size: 26),
      ),
    );
  }

  Widget _buildPersonCard(
    ColorScheme colorScheme,
    TextTheme textTheme,
    Person person,
  ) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openDetailScreen(person),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              PersonAvatar(
                photoUrl: person.photoUrl,
                fullName: person.fullName,
                radius: 24,
                heroTag: person.id != null
                    ? 'person-avatar-${person.id}'
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      person.department,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline_rounded,
                size: 36,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Kayıtlı kişi bulunamadı',
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              'Sağ alttaki + butonuna dokunarak yeni kişi ekleyebilirsiniz.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    ColorScheme colorScheme,
    TextTheme textTheme,
    String errorMessage,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.cloud_off_rounded,
                    size: 32,
                    color: colorScheme.error,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Sunucuya Bağlanılamadı',
                  style: textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    FilledButton.icon(
                      onPressed: _refreshList,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Tekrar Dene'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _showApiUrlDialog,
                      icon: const Icon(Icons.tune_rounded, size: 18),
                      label: const Text('URL Ayarla'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
