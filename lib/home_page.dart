import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = true;
  List _stokKritis = [];
  List _grafikPenjualan = [];

  @override
  void initState() {
    super.initState();
    _fetchLaporanDashboard();
  }

  Future<void> _fetchLaporanDashboard() async {
    try {
      // Mengambil data Peringatan Stok
      final responseStok = await http.get(Uri.parse('http://10.0.2.2:3000/api/stok-menipis'));
      // Mengambil data Grafik Penjualan
      final responseGrafik = await http.get(Uri.parse('http://10.0.2.2:3000/api/grafik-penjualan'));

      if (responseStok.statusCode == 200 && responseGrafik.statusCode == 200) {
        setState(() {
          _stokKritis = json.decode(responseStok.body);
          _grafikPenjualan = json.decode(responseGrafik.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // Fungsi untuk memformat tanggal (misal: 2026-06-20 jadi 20/6)
  String _formatTanggal(String tanggalAsli) {
    DateTime dt = DateTime.parse(tanggalAsli);
    return "${dt.day}/${dt.month}";
  }

  @override
  Widget build(BuildContext context) {
    // Mencari nilai pendapatan tertinggi untuk skala tinggi grafik batang
    double maxPendapatan = 1.0;
    for (var item in _grafikPenjualan) {
      double pendapatan = (item['total_pendapatan'] as num).toDouble();
      if (pendapatan > maxPendapatan) maxPendapatan = pendapatan;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Halo, Admin Warung! 👋', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
            Text('Ringkasan performa warungmu hari ini', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchLaporanDashboard,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    // SECTION 1: NOTIFIKASI STOK MENIPIS
                    if (_stokKritis.isNotEmpty) ...[
                      const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Peringatan Stok Menipis!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Column(
                          children: _stokKritis.map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(item['nama_produk'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
                                    child: Text('Sisa: ${item['stok']}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                                  )
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],

                    // SECTION 2: GRAFIK PENJUALAN HARIAN
                    const Text('Grafik Penjualan (7 Hari Terakhir)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    Container(
                      height: 250,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 10)],
                      ),
                      child: _grafikPenjualan.isEmpty
                          ? const Center(child: Text('Belum ada data transaksi'))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: _grafikPenjualan.map((data) {
                                double persentaseTinggi = (data['total_pendapatan'] as num) / maxPendapatan;
                                
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // Tooltip nilai di atas grafik batang
                                    Text(
                                      '${((data['total_pendapatan'] as num) / 1000).toInt()}k', 
                                      style: const TextStyle(fontSize: 10, color: Colors.grey)
                                    ),
                                    const SizedBox(height: 5),
                                    // Batang Grafik
                                    Container(
                                      width: 25,
                                      height: 150 * persentaseTinggi, // Maksimal tinggi batang 150
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF005088),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    // Label Tanggal
                                    Text(_formatTanggal(data['tanggal']), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                  ],
                                );
                              }).toList(),
                            ),
                    ),
                    const SizedBox(height: 30),

                    // Tambahan spasi bawah agar tidak tertutup Bottom Navigation Bar
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
    );
  }
}