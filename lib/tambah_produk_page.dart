import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'katalog_page.dart';

class TambahProdukPage extends StatefulWidget {
  const TambahProdukPage({super.key});

  @override
  State<TambahProdukPage> createState() => _TambahProdukPageState();
}

class _TambahProdukPageState extends State<TambahProdukPage> {
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
  Future<void> _simpanData() async {
    if (_namaController.text.isEmpty ||
        _hargaController.text.isEmpty ||
        _stokController.text.isEmpty ||
        _kategoriTerpilih == null ||
        _satuanTerpilih == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap isi semua data!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    const String urlApi = 'http://10.0.2.2:3000/api/produk';

    try {
      final response = await http.post(
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

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produk Berhasil Ditambahkan!'),
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
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tambah Produk Baru',
          style: TextStyle(
            color: Colors.black,
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
            const Text(
              'Komponen Foto Barang',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, color: Colors.grey),
                  SizedBox(height: 5),
                  Text(
                    'Unggah Foto\nBarang',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Kolom Input Utama',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            _labelInput('Nama Produk'),
            _kotakInput(
              TextField(
                controller: _namaController,
                decoration: const InputDecoration(
                  hintText: 'Contoh : Buku Tulis 38 Lembar',
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
                      color: Color(0xFFFF823A), // Warna Oranye
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

            // Stok Awal
            _labelInput('Stok Awal'),
            _kotakInput(
              TextField(
                controller: _stokController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 15),
                ),
              ),
            ),

            _labelInput('Satuan Barang'),
            _kotakInput(
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  value: _satuanTerpilih,
                  items: _satuanList
                      .map(
                        (String val) =>
                            DropdownMenuItem(value: val, child: Text(val)),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _satuanTerpilih = val),
                ),
              ),
            ),

            _labelInput('Batas Stok Minimum'),
            _kotakInput(
              TextField(
                controller: _batasStokController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 15),
                ),
              ),
            ),

            const SizedBox(height: 30),
            // Tombol Simpan
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005088),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _simpanData,
                child: const Text(
                  'Simpan Data',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
