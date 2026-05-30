import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'katalog_page.dart';

class EditProdukPage extends StatefulWidget {
  final Map produk;

  const EditProdukPage({super.key, required this.produk});

  @override
  State<EditProdukPage> createState() => _EditProdukPageState();
}

class _EditProdukPageState extends State<EditProdukPage> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();
  final TextEditingController _batasStokController = TextEditingController();

  String? _kategoriTerpilih;
  String? _satuanTerpilih;

  final List<String> _kategoriList = [
    'Sembako',
    'Jajanan',
    'Rokok',
    'Es Krim',
    'ATK',
  ];
  final List<String> _satuanList = ['Pcs', 'Kg', 'Liter', 'Bungkus', 'Slop'];

  @override
  void initState() {
    super.initState();
    _namaController.text = widget.produk['nama_produk'];
    _hargaController.text = widget.produk['harga'].toString();
    _stokController.text = widget.produk['stok'].toString();
    _batasStokController.text = widget.produk['batas_stok'].toString();
    _kategoriTerpilih = widget.produk['kategori'];
    _satuanTerpilih = widget.produk['satuan'];
  }

  Future<void> _updateData() async {
    final int idProduk = widget.produk['id'];
    final String urlApi = 'http://10.0.2.2:3000/api/produk/$idProduk';

    try {
      final response = await http.put(
        Uri.parse(urlApi),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nama_produk': _namaController.text,
          'kategori': _kategoriTerpilih,
          'harga': int.parse(_hargaController.text),
          'stok': int.parse(_stokController.text),
          'satuan': _satuanTerpilih,
          'batas_stok': int.parse(_batasStokController.text),
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perubahan Berhasil Disimpan!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const KatalogPage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Widget _labelInput(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
    );
  }

  Widget _kotakInput(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF823A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Ubah Informasi Produk',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _labelInput('Nama Produk'),
            _kotakInput(
              TextField(
                controller: _namaController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 15),
                ),
              ),
            ),

            _labelInput('Kategori Produk'),
            _kotakInput(
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  value: _kategoriTerpilih,
                  items: _kategoriList
                      .map(
                        (String val) =>
                            DropdownMenuItem(value: val, child: Text(val)),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _kategoriTerpilih = val),
                ),
              ),
            ),

            _labelInput('Harga Jual'),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 14,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF823A),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Rp',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _hargaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005088), // Biru Gelap
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _updateData,
                child: const Text(
                  'Simpan Perubahan',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
