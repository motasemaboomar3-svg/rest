import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  LatLng _picked = LatLng(33.5138, 36.2765);

  Future<void> _save() async {
    if (_name.text.trim().isEmpty || _phone.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أدخل الاسم ورقم الهاتف')));
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('customer_name', _name.text.trim());
    await prefs.setString('customer_phone', _phone.text.trim());
    await prefs.setDouble('customer_lat', _picked.latitude);
    await prefs.setDouble('customer_lng', _picked.longitude);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('البيانات الأساسية')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'الاسم')),
          const SizedBox(height: 12),
          TextField(controller: _phone, decoration: const InputDecoration(labelText: 'رقم الهاتف'), keyboardType: TextInputType.phone),
          const SizedBox(height: 16),
          const Text('اختر موقعك على الخريطة:'),
          const SizedBox(height: 8),
          SizedBox(
            height: 320,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _picked,
                initialZoom: 13,
                onTap: (tapPos, latlng) => setState(() => _picked = latlng),
              ),
              children: [
                TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'customer_app'),
                MarkerLayer(markers: [
                  Marker(point: _picked, width: 40, height: 40, child: const Icon(Icons.location_on, size: 40)),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: _save, child: const Text('حفظ والمتابعة')),
        ],
      ),
    );
  }
}
