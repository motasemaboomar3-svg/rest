import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_client.dart';
import 'track_order_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool loading = true;
  List orders = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final phone = prefs.getString('customer_phone') ?? '';
      final api = ApiClient();
      final data = await api.getJson('/api/customers/orders', q: {'phone': phone});
      orders = (data as List);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ تحميل الطلبات: $e')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلباتي'), actions: [
        IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
      ]),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(child: Text('لا يوجد طلبات'))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemBuilder: (context, idx) {
                    final o = orders[idx];
                    return ListTile(
                      title: Text('طلب رقم #${o["id"]}'),
                      subtitle: Text('الحالة: ${o["status"]}'),
                      trailing: const Icon(Icons.map),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => TrackOrderScreen(orderId: o['id'])),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemCount: orders.length,
                ),
    );
  }
}
