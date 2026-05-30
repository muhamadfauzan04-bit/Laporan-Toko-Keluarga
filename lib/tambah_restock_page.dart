import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class TambahRestockPage extends StatefulWidget {
  const TambahRestockPage({super.key});

  @override
  State<TambahRestockPage> createState() => _TambahRestockPageState();
}

class _TambahRestockPageState extends State<TambahRestockPage> {
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _supplierController = TextEditingController();
  
  String? _selectedProdukId;
  DateTime _selectedDate = DateTime.now();
  List _produkList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchProduk(); // Ambil data katalog untuk dropdown
  }

  // Mengambil daftar produk untuk Dropdown
  Future<void> _fetchProduk() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/api/produk'));
      if (response.statusCode == 200) {
        setState(() {
          _produkList = json.decode(response.body);
        });
      }
    } catch (e) {
      print("Error ambil produk: $e");
    }
  }

  // Fungsi memunculkan kalender
  Future<void> _pilihTanggal(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Fungsi simpan data ke API
  Future<void> _simpanStok() async {
    if (_selectedProdukId == null || _jumlahController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih produk dan isi jumlahnya!')),
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/restock'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id_produk': _selectedProdukId,
          'jumlah_masuk': int.parse(_jumlahController.text),
          'tanggal_masuk': DateFormat('yyyy-MM-dd').format(_selectedDate),
          'supplier': _supplierController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stok berhasil ditambahkan!')),
        );
        Navigator.pop(context, true); // Kembali ke halaman sebelumnya dan bawa sinyal 'true'
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan data')),
      );
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  // Widget bantuan untuk judul input
  Widget _labelInput(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Catat Barang Masuk',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _labelInput('Pilih Produk'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EDF2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text('Pilih Produk Dari Katalog'),
                  value: _selectedProdukId,
                  items: _produkList.map((item) {
                    return DropdownMenuItem<String>(
                      value: item['id'].toString(),
                      child: Text(item['nama_produk']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedProdukId = value;
                    });
                  },
                ),
              ),
            ),

            _labelInput('Jumlah Masuk (Input Angka)'),
            TextField(
              controller: _jumlahController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Contoh : 15',
                filled: true,
                fillColor: const Color(0xFFE8EDF2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            _labelInput('Tanggal Masuk'),
            InkWell(
              onTap: () => _pilihTanggal(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EDF2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat('dd MMMM yyyy').format(_selectedDate)),
                    const Icon(Icons.calendar_today, color: Color(0xFF005088)),
                  ],
                ),
              ),
            ),

            _labelInput('Nama Distributor/Supplier'),
            TextField(
              controller: _supplierController,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFE8EDF2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _simpanStok,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005088),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Simpan Stok', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}