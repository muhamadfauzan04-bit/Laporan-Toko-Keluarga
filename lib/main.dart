import 'package:flutter/material.dart';
import 'riwayat_restock_page.dart';
import 'login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WARUNG.IN',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF005088),
          primary: const Color(0xFF005088),
          secondary: const Color(0xFFFF823A),
        ),
        useMaterial3: true,
      ),
      home: const RiwayatRestockPage(),
    );
  }
}
