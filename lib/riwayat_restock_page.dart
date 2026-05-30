import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'tambah_restock_page.dart';

class RiwayatRestockPage extends StatefulWidget {
  const RiwayatRestockPage({super.key});

  @override
  State<RiwayatRestockPage> createState() => _RiwayatRestockPageState();
}

class _RiwayatRestockPageState extends State<RiwayatRestockPage> {
  List _riwayatList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRiwayat();
  }

  // Fungsi untuk menarik data dari API Node.js
  Future<void> _fetchRiwayat() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/api/restock'));
      if (response.statusCode == 200) {
        setState(() {
          _riwayatList = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        // TAMBAHAN BARU: Hentikan muter-muter kalau server merespons error (misal 404/500)
        setState(() {
          _isLoading = false;
        });
        print("Server error dengan status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error koneksi: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Warna abu-abu sangat muda agar card terlihat
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Riwayat Barang Masuk',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Color(0xFF005088)), // Ikon filter biru
            onPressed: () {},
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF005088)))
          : _riwayatList.isEmpty
              ? const Center(child: Text("Belum ada riwayat barang masuk."))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _riwayatList.length,
                  itemBuilder: (context, index) {
                    final item = _riwayatList[index];
                    
                    // Memotong format tanggal dari database (contoh: 2026-05-26T00:00:00Z jadi 2026-05-26)
                    String tgl = item['tanggal_masuk'].toString().substring(0, 10);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['nama_produk'] ?? 'Produk Tidak Diketahui',
                                  style: const TextStyle(
                                    color: Color(0xFFFF823A), // Warna Oranye WARUNG.IN
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '+ $tgl',
                                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item['supplier'] ?? '-',
                                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '+ ${item['jumlah_masuk']} Pcs',
                            style: const TextStyle(
                              color: Color(0xFF005088), // Warna Biru WARUNG.IN
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF005088),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
        onPressed: () async {
          // Buka halaman form, dan tunggu hasilnya
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TambahRestockPage()),
          );

          // Jika ada sinyal 'true' (berarti data berhasil ditambah), refresh riwayatnya
          if (result == true) {
            _fetchRiwayat();
          }
        },
      ),
    );
  }
}