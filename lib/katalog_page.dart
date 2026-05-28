import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'edit_produk_page.dart';
import 'tambah_produk_page.dart';

class KatalogPage extends StatefulWidget {
  const KatalogPage({super.key});

  @override
  State<KatalogPage> createState() => _KatalogPageState();
}

class _KatalogPageState extends State<KatalogPage> {
  List _produkList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _ambilDataProduk();
  }

  Future<void> _ambilDataProduk() async {
    const String urlApi = 'http://localhost:3000/api/produk';
    try {
      final response = await http.get(Uri.parse(urlApi));
      if (response.statusCode == 200) {
        setState(() {
          _produkList = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _notifikasiAplikasi('Gagal memuat data: $e', Colors.red);
    }
  }

  Future<void> _eksekusiHapusProduk(int id) async {
    final String urlApi = 'http://localhost:3000/api/produk/$id';
    try {
      final response = await http.delete(Uri.parse(urlApi));
      if (response.statusCode == 200) {
        _notifikasiAplikasi('Produk berhasil dihapus!', Colors.green);
        _ambilDataProduk();
      }
    } catch (e) {
      _notifikasiAplikasi('Gagal menghapus produk: $e', Colors.red);
    }
  }

  void _tampilkanDialogHapus(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_rounded,
                  color: Color(0xFFFF823A),
                  size: 50,
                ),
                const SizedBox(height: 16),

                const Text(
                  'Hapus produk ini secara permanen?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),

                const Text(
                  'Data yang dihapus tidak dapat dipulihkan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF823A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _eksekusiHapusProduk(id);
                      },
                      child: const Text(
                        'Hapus Sekarang',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _notifikasiAplikasi(String pesan, Color warnaBg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(pesan), backgroundColor: warnaBg));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Katalog Produk',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Cari Nama Produk...',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _produkList.isEmpty
                ? const Center(child: Text('Belum ada produk di katalog.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: _produkList.length,
                    itemBuilder: (context, index) {
                      final produk = _produkList[index];
                      bool stokAman = produk['stok'] > produk['batas_stok'];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 5,
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
                                  produk['nama_produk'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'Rp ${produk['harga']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF005088),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Kategori : ${produk['kategori']}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: stokAman
                                        ? const Color(0xFF005088)
                                        : const Color(0xFFFF823A),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Stok : ${produk['stok']} ${produk['satuan']}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const Spacer(),

                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditProdukPage(produk: produk),
                                      ),
                                    );
                                  },
                                  child: const Icon(
                                    Icons.edit_outlined,
                                    color: Colors.black54,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 15),

                                GestureDetector(
                                  onTap: () => _tampilkanDialogHapus(
                                    context,
                                    produk['id'],
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline,
                                    color: Color(0xFFFF823A),
                                    size: 22,
                                  ),
                                ),
                              ],
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TambahProdukPage()),
          );
        },
        backgroundColor: const Color(0xFF005088),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
