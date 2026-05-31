import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class TambahBarangKeluarPage extends StatefulWidget {
  const TambahBarangKeluarPage({super.key});

  @override
  State<TambahBarangKeluarPage> createState() => _TambahBarangKeluarPageState();
}

class _TambahBarangKeluarPageState extends State<TambahBarangKeluarPage> {
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();
  
  String? _selectedProdukId;
  DateTime _selectedDate = DateTime.now();
  List _produkList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchProduk(); 
  }

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

  Future<void> _simpanData() async {
    if (_selectedProdukId == null || _jumlahController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih produk dan isi jumlah keluar!')),
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/barang-keluar'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id_produk': _selectedProdukId,
          'jumlah_keluar': int.parse(_jumlahController.text),
          'tanggal_keluar': DateFormat('yyyy-MM-dd').format(_selectedDate),
          'keterangan': _keteranganController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil! Stok otomatis berkurang.')),
        );
        Navigator.pop(context, true); 
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan data')),
      );
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  Widget _labelInput(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
      child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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
          'Catat Barang Keluar',
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
                    setState(() { _selectedProdukId = value; });
                  },
                ),
              ),
            ),

            _labelInput('Jumlah Keluar (Input Angka)'),
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

            _labelInput('Tanggal Keluar'),
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

            _labelInput('Keterangan / Pembeli'),
            TextField(
              controller: _keteranganController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Contoh: Pak Budi Kasbon / Barang Rusak',
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
                onPressed: _isLoading ? null : _simpanData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005088),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Simpan Data', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}