import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'screens/splash_screen.dart';

void main() {
  Intl.defaultLocale = 'ar';
  runApp(const CustomerApp());
}

class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'تطبيق الزبون',
      theme: ThemeData(useMaterial3: true),
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
      home: const SplashScreen(),
    );
  }
}
