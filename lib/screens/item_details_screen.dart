import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_client.dart';
import 'cart_screen.dart';

class ItemDetailsScreen extends StatefulWidget {
  final int itemId;
  const ItemDetailsScreen({super.key, required this.itemId});

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  final api = ApiClient();
  bool loading = true;
  Map item = {};
  int qty = 1;
  final Map<int, Set<int>> selectedOptions = {}; // groupId -> optionItemIds

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await api.getJson('/api/catalog/items/${widget.itemId}');
      item = (data as Map);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _addToCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cart = (prefs.getStringList('cart_json') ?? []).toList();

    final payload = {
      'itemId': item['id'],
      'name': item['name'],
      'price': item['price'],
      'qty': qty,
      'selectedOptionItemIds': selectedOptions.values.expand((s) => s).toList(),
    };
    cart.add(json.encode(payload));
    await prefs.setStringList('cart_json', cart);

    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CartScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item['name'] ?? 'تفاصيل الصنف')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(item['description'] ?? '', style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('الكمية:'),
                    const SizedBox(width: 8),
                    IconButton(onPressed: qty > 1 ? () => setState(() => qty--) : null, icon: const Icon(Icons.remove)),
                    Text('$qty'),
                    IconButton(onPressed: () => setState(() => qty++), icon: const Icon(Icons.add)),
                    const Spacer(),
                    Text('السعر: ${item['price']}'),
                  ],
                ),
                const Divider(),
                if (item['optionGroups'] is List)
                  ...((item['optionGroups'] as List).map((g) {
                    final groupId = g['id'] as int;
                    final required = g['required'] == true;
                    final max = (g['max'] ?? 1) as int;
                    final options = (g['options'] as List? ?? []);
                    selectedOptions.putIfAbsent(groupId, () => <int>{});
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${g['name']} ${required ? "(إجباري)" : ""}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            ...options.map((o) {
                              final oid = o['id'] as int;
                              final name = o['name'];
                              final delta = o['priceDelta'] ?? 0;
                              final set = selectedOptions[groupId]!;
                              final checked = set.contains(oid);
                              return CheckboxListTile(
                                value: checked,
                                title: Text('$name ${delta != 0 ? "(+$delta)" : ""}'),
                                onChanged: (v) {
                                  setState(() {
                                    if (v == true) {
                                      if (set.length >= max) return;
                                      set.add(oid);
                                    } else {
                                      set.remove(oid);
                                    }
                                  });
                                },
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  })),
                const SizedBox(height: 12),
                FilledButton.icon(onPressed: _addToCart, icon: const Icon(Icons.add_shopping_cart), label: const Text('إضافة للسلة')),
              ],
            ),
    );
  }
}
