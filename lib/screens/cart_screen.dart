import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_client.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<String> raw = [];
  bool sending = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => raw = prefs.getStringList('cart_json') ?? []);
  }

  Future<void> _sendOrder() async {
    setState(() => sending = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('customer_name') ?? '';
      final phone = prefs.getString('customer_phone') ?? '';
      final lat = prefs.getDouble('customer_lat');
      final lng = prefs.getDouble('customer_lng');

      final items = raw.map((s) => json.decode(s) as Map<String, dynamic>).toList();

      final api = ApiClient();
      final body = {
        'customerName': name,
        'customerPhone': phone,
        'customerLat': lat,
        'customerLng': lng,
        'items': items,
      };

      await api.postJson('/api/orders', body);
      await prefs.remove('cart_json');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال الطلب')));
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل إرسال الطلب: $e')));
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('السلة')),
      body: raw.isEmpty
          ? const Center(child: Text('السلة فارغة'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...raw.map((e) {
                  final m = json.decode(e) as Map<String, dynamic>;
                  return Card(
                    child: ListTile(
                      title: Text(m['name'] ?? ''),
                      subtitle: Text('الكمية: ${m['qty']}'),
                      trailing: Text('${m['price']}'),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: sending ? null : _sendOrder,
                  child: Text(sending ? 'جارٍ الإرسال...' : 'تأكيد الطلب'),
                ),
              ],
            ),
    );
  }
}
