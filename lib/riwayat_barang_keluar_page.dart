import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'tambah_barang_keluar_page.dart';
import 'profil_page.dart';

class RiwayatBarangKeluarPage extends StatefulWidget {
  const RiwayatBarangKeluarPage({super.key});

  @override
  State<RiwayatBarangKeluarPage> createState() => _RiwayatBarangKeluarPageState();
}

class _RiwayatBarangKeluarPageState extends State<RiwayatBarangKeluarPage> {
  List _riwayatList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRiwayat();
  }

  Future<void> _fetchRiwayat() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/api/barang-keluar'));
      if (response.statusCode == 200) {
        setState(() {
          _riwayatList = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() { _isLoading = false; });
      }
    } catch (e) {
      print("Error: $e");
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        automaticallyImplyLeading: false, // Menghilangkan panah back
        title: const Text(
          'Riwayat Barang Keluar',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilPage()));
              },
              child: const CircleAvatar(
                backgroundColor: Color(0xFF005088),
                radius: 16,
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF005088)))
                : _riwayatList.isEmpty
                    ? const Center(child: Text("Belum ada riwayat barang keluar."))
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _riwayatList.length,
                        itemBuilder: (context, index) {
                          final item = _riwayatList[index];
                          
                          String tgl = "-";
                          if (item['tanggal_keluar'] != null && item['tanggal_keluar'].toString().length >= 10) {
                            tgl = item['tanggal_keluar'].toString().substring(0, 10);
                          }

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
                                        item['nama_produk'] ?? 'Produk',
                                        style: const TextStyle(
                                          color: Color(0xFFFF823A), 
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(tgl, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                      const SizedBox(height: 2),
                                      Text(item['keterangan'] ?? '-', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                    ],
                                  ),
                                ),
                                Text(
                                  '- ${item['jumlah_keluar']} Pcs',
                                  style: const TextStyle(
                                    color: Color(0xFF005088),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF005088),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TambahBarangKeluarPage()),
          );
          if (result == true) {
            _fetchRiwayat();
          }
        },
      ),
    );
  }
}