import 'package:flutter/material.dart';
import 'home_page.dart';
import 'kasir_page.dart'; // Import halaman Kasir yang baru dibuat
import 'katalog_page.dart'; 
import 'riwayat_restock_page.dart';
import 'riwayat_barang_keluar_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // 1. Tambahkan KasirPage() ke dalam daftar halaman
  final List<Widget> _pages = [
    const HomePage(),
    const KasirPage(), // Letakkan Kasir setelah Home agar alurnya enak
    const KatalogPage(), 
    const RiwayatRestockPage(),
    const RiwayatBarangKeluarPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: _pages[_selectedIndex], 
      
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 10, right: 10, bottom: 15), // Sedikit disesuaikan ukurannya agar pas 5 menu
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed, // Tetap fixed agar 5 menu muat berjejer
            backgroundColor: Colors.white,
            elevation: 0,
            selectedItemColor: const Color(0xFF005088),
            unselectedItemColor: Colors.grey,
            showSelectedLabels: true,
            showUnselectedLabels: false, // Menyembunyikan label yang tidak dipilih agar tidak terlalu padat
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            // 2. Tambahkan item BottomNavigationBarItem untuk Kasir
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.point_of_sale_rounded), label: 'Kasir'), // Menu Kasir Baru
              BottomNavigationBarItem(icon: Icon(Icons.inventory_2_rounded), label: 'Katalog'),
              BottomNavigationBarItem(icon: Icon(Icons.download_rounded), label: 'Masuk'),
              BottomNavigationBarItem(icon: Icon(Icons.upload_rounded), label: 'Keluar'),
            ],
          ),
        ),
      ),
    );
  }
}