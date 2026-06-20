import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CheckoutPage extends StatefulWidget {
  final List keranjang;
  final int totalTagihan;

  const CheckoutPage({
    super.key,
    required this.keranjang,
    required this.totalTagihan,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final TextEditingController _uangController = TextEditingController();
  int _kembalian = 0;
  bool _isLoading = false;

  void _hitungKembalian(String input) {
    if (input.isEmpty) {
      setState(() => _kembalian = 0);
      return;
    }
    int uang = int.tryParse(input.replaceAll('.', '')) ?? 0;
    setState(() {
      _kembalian = uang - widget.totalTagihan;
    });
  }

  Future<void> _selesaikanTransaksi() async {
    if (_uangController.text.isEmpty || _kembalian < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Uang pembayaran kurang atau belum diisi!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    List keranjangAPI = widget.keranjang.map((item) {
      return {
        'id_produk': item['id_produk'],
        'jumlah': item['qty'],
        'subtotal': item['qty'] * item['harga'],
      };
    }).toList();

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/transaksi'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'total_tagihan': widget.totalTagihan,
          'uang_diterima': int.parse(_uangController.text.replaceAll('.', '')),
          'kembalian': _kembalian,
          'keranjang': keranjangAPI,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaksi Berhasil Disimpan!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal koneksi ke server.')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Pembayaran',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kotak Struk
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  ...widget.keranjang.map((item) {
                    int sub = item['qty'] * item['harga'];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item['nama_produk']} x ${item['qty']}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          Text('Rp $sub', style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    );
                  }).toList(),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      '----------------------------------------------------',
                      style: TextStyle(color: Colors.grey),
                      maxLines: 1,
                    ),
                  ),

                  Text(
                    'Total Tagihan: Rp ${widget.totalTagihan}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Input Uang
            const Text(
              'Uang Diterima (Rp)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE8EDF2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _uangController,
                keyboardType: TextInputType.number,
                onChanged: _hitungKembalian,
                decoration: const InputDecoration(
                  hintText: 'Contoh: 100000',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Info Kembalian
            Center(
              child: Text(
                'Kembalian : Rp $_kembalian',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _kembalian < 0 ? Colors.red : const Color(0xFFFF823A),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005088),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: _isLoading ? null : _selesaikanTransaksi,
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Selesaikan Transaksi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
