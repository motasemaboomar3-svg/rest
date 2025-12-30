import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/api_client.dart';

class TrackOrderScreen extends StatefulWidget {
  final int orderId;
  const TrackOrderScreen({super.key, required this.orderId});

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {
  final api = ApiClient();
  bool loading = true;
  Map data = {};
  LatLng center = LatLng(33.5138, 36.2765);

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => loading = true);
    try {
      final d = await api.getJson('/api/orders/${widget.orderId}/track');
      data = (d as Map);
      final cust = data['customer'];
      if (cust != null && cust['lat'] != null) {
        center = LatLng((cust['lat'] as num).toDouble(), (cust['lng'] as num).toDouble());
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cust = data['customer'];
    final drv = data['driver'];
    final markers = <Marker>[];
    if (cust != null && cust['lat'] != null) {
      markers.add(Marker(
        point: LatLng((cust['lat'] as num).toDouble(), (cust['lng'] as num).toDouble()),
        width: 40, height: 40,
        child: const Icon(Icons.location_on, size: 40),
      ));
    }
    if (drv != null && drv['lat'] != null) {
      markers.add(Marker(
        point: LatLng((drv['lat'] as num).toDouble(), (drv['lng'] as num).toDouble()),
        width: 40, height: 40,
        child: const Icon(Icons.delivery_dining, size: 40),
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('تتبع الطلب #${widget.orderId}'),
        actions: [IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh))],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: MapOptions(initialCenter: center, initialZoom: 13),
              children: [
                TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'customer_app'),
                MarkerLayer(markers: markers),
              ],
            ),
    );
  }
}
