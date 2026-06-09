import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'checkout_page.dart'; // Menyambungkan ke file kedua

class KasirPage extends StatefulWidget {
  const KasirPage({super.key});

  @override
  State<KasirPage> createState() => _KasirPageState();
}

class _KasirPageState extends State<KasirPage> {
  List _produkList = [];
  bool _isLoading = true;
  
  // Format keranjang: { id_produk: { nama, harga, qty } }
  Map<int, dynamic> _keranjang = {}; 

  @override
  void initState() {
    super.initState();
    _ambilDataProduk();
  }

  Future<void> _ambilDataProduk() async {
    const String urlApi = 'http://10.0.2.2:3000/api/produk';
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
    }
  }

  void _tambahQty(Map produk) {
    int id = produk['id'];
    setState(() {
      if (_keranjang.containsKey(id)) {
        if (_keranjang[id]['qty'] < produk['stok']) {
          _keranjang[id]['qty']++;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Stok tidak mencukupi!'), duration: Duration(seconds: 1)),
          );
        }
      } else {
        if (produk['stok'] > 0) {
          _keranjang[id] = {
            'id_produk': id,
            'nama_produk': produk['nama_produk'],
            'harga': produk['harga'],
            'qty': 1
          };
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Stok habis!'), duration: Duration(seconds: 1)),
          );
        }
      }
    });
  }

  void _kurangQty(int id) {
    setState(() {
      if (_keranjang.containsKey(id)) {
        if (_keranjang[id]['qty'] > 1) {
          _keranjang[id]['qty']--;
        } else {
          _keranjang.remove(id);
        }
      }
    });
  }

  int _hitungTotal() {
    int total = 0;
    _keranjang.forEach((key, item) {
      total += (item['harga'] as int) * (item['qty'] as int);
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    int totalHarga = _hitungTotal();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Transaksi Baru', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Kotak Pencarian
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EDF2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Colors.grey),
                  hintText: 'Cari Produk.....',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          // Daftar Produk
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _produkList.length,
                    itemBuilder: (context, index) {
                      final produk = _produkList[index];
                      int id = produk['id'];
                      int qty = _keranjang.containsKey(id) ? _keranjang[id]['qty'] : 0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 8),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(produk['nama_produk'], style: const TextStyle(color: Color(0xFFFF823A), fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 5),
                                  Text('Rp ${produk['harga']}', style: const TextStyle(color: Color(0xFF005088), fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 5),
                                  Text('Sisa : ${produk['stok']} Pcs', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ),
                            
                            // Tombol Plus Minus (Counter)
                            Row(
                              children: [
                                InkWell(
                                  onTap: () => _kurangQty(id),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(color: const Color(0xFF005088), borderRadius: BorderRadius.circular(4)),
                                    child: const Icon(Icons.remove, color: Colors.white, size: 20),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                ),
                                InkWell(
                                  onTap: () => _tambahQty(produk),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(color: const Color(0xFF005088), borderRadius: BorderRadius.circular(4)),
                                    child: const Icon(Icons.add, color: Colors.white, size: 20),
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

          // Bottom Bar Keranjang
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: const BoxDecoration(
              color: Color(0xFF005088),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 30),
                    const SizedBox(width: 10),
                    Text('Total : Rp $totalHarga', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF823A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _keranjang.isEmpty ? null : () {
                    // Pindah ke Halaman Checkout dan bawa data keranjang
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckoutPage(
                          keranjang: _keranjang.values.toList(),
                          totalTagihan: totalHarga,
                        ),
                      ),
                    ).then((value) {
                      // Jika checkout sukses dan kembali ke sini, reset keranjang & refresh produk
                      if (value == true) {
                        setState(() { _keranjang.clear(); });
                        _ambilDataProduk();
                      }
                    });
                  },
                  child: const Text('Checkout >', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}