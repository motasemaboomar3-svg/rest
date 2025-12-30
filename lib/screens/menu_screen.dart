import 'package:flutter/material.dart';
import '../services/api_client.dart';
import 'item_details_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final api = ApiClient();
  bool loading = true;
  List categories = [];
  List items = [];
  int? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final cats = await api.getJson('/api/catalog/categories');
      setState(() {
        categories = (cats as List);
        selectedCategoryId = categories.isNotEmpty ? categories.first['id'] : null;
      });
      await _loadItems();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ تحميل المنيو: $e')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _loadItems() async {
    if (selectedCategoryId == null) {
      setState(() => items = []);
      return;
    }
    final data = await api.getJson('/api/catalog/items', q: {'categoryId': selectedCategoryId});
    setState(() => items = (data as List));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المنيو')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (categories.isNotEmpty)
                  SizedBox(
                    height: 56,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, idx) {
                        final c = categories[idx];
                        final isSel = c['id'] == selectedCategoryId;
                        return ChoiceChip(
                          label: Text(c['name'] ?? ''),
                          selected: isSel,
                          onSelected: (_) async {
                            setState(() => selectedCategoryId = c['id']);
                            await _loadItems();
                          },
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemCount: categories.length,
                    ),
                  ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemBuilder: (context, idx) {
                      final it = items[idx];
                      return ListTile(
                        title: Text(it['name'] ?? ''),
                        subtitle: Text(it['description'] ?? ''),
                        trailing: Text('${it['price'] ?? ''}'),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => ItemDetailsScreen(itemId: it['id'])),
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemCount: items.length,
                  ),
                ),
              ],
            ),
    );
  }
}
