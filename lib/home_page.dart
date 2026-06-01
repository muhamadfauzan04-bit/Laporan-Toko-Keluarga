import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'profil_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _totalProduk = 0;
  int _totalMasuk = 0;
  int _totalKeluar = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/api/dashboard'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _totalProduk = data['total_produk'];
          _totalMasuk = int.parse(data['total_masuk'].toString());
          _totalKeluar = int.parse(data['total_keluar'].toString());
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching dashboard: $e");
      setState(() { _isLoading = false; });
    }
  }

  // Widget custom untuk membuat kartu statistik agar codingan lebih rapi
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Halo, Fauzan ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
            Text('Ringkasan WARUNG.IN hari ini', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilPage()));
              },
              child: const CircleAvatar(
                backgroundColor: Color(0xFF005088),
                radius: 18,
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
            ),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF005088)))
          : RefreshIndicator(
              onRefresh: _fetchDashboardData, // Tarik layar ke bawah untuk refresh
              color: const Color(0xFF005088),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Kartu Total Produk (Besar membentang)
                  _buildStatCard(
                    'TOTAL MACAM PRODUK',
                    '$_totalProduk Item',
                    Icons.inventory_2_rounded,
                    const Color(0xFF005088),
                  ),
                  const SizedBox(height: 20),
                  
                  // Grid untuk Barang Masuk & Barang Keluar (Bersebelahan)
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'TOTAL MASUK',
                          '+ $_totalMasuk',
                          Icons.download_rounded,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildStatCard(
                          'TOTAL KELUAR',
                          '- $_totalKeluar',
                          Icons.upload_rounded,
                          const Color(0xFFFF823A), // Menggunakan warna orange khas aplikasi
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Banner Info / Tips (Biar UI lebih padat & cantik)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF005088), Color(0xFF003050)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tips Hari Ini 💡',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Jangan lupa cek menu Katalog untuk melihat stok barang yang sudah mulai menipis ya!',
                                style: TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Image.network(
                          'https://cdn-icons-png.flaticon.com/512/3214/3214746.png', // Icon illustrasi
                          width: 60,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}