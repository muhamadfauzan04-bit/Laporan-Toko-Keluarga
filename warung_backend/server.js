// Memanggil pustaka yang sudah diinstall tadi
const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');

const app = express();

// Mengaktifkan fitur keamanan CORS dan pembaca data format JSON
app.use(cors());
app.use(express.json()); 

// Mengatur konfigurasi alamat koneksi ke XAMPP MySQL kita
const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',       // Username default XAMPP adalah root
    password: '',       // Password default XAMPP adalah kosong/tidak ada
    database: 'warung_in_db' // Nama database yang kita buat di Tahap 1
});

// Menghubungkan ke database
db.connect((err) => {
    if (err) {
        console.error('Gagal menyambung ke MySQL:', err.message);
        return;
    }
    console.log('Hebat! Database MySQL Sukses Terhubung!');
});

// ========================================================
// JALUR 1: API LOGIN ADMIN (POST METHOD)
// ========================================================
// Flutter akan mengirim data username & password ke URL ini
app.post('/api/login', (req, res) => {
    const { username, password } = req.body; // Menangkap ketikan dari layar HP
    
    // Perintah SQL untuk mencocokkan ketikan user dengan isi database
    const sql = 'SELECT * FROM admin WHERE username = ? AND password = ?';
    
    db.query(sql, [username, password], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        
        if (results.length > 0) {
            // Jika data ditemukan (cocok)
            res.status(200).json({ message: 'Login Sukses', user: results[0] });
        } else {
            // Jika salah password atau username tidak ada
            res.status(401).json({ message: 'Maaf, Username atau Password salah!' });
        }
    });
});

// ========================================================
// JALUR 2: API AMBIL DAFTAR PRODUK (GET METHOD)
// ========================================================
// JALUR 3: API TAMBAH PRODUK BARU (POST METHOD)
// ========================================================
app.post('/api/produk', (req, res) => {
    // Menangkap data yang dikirim dari form Flutter
    const { nama_produk, kategori, harga, stok, satuan, batas_stok } = req.body;
    
    // Perintah memasukkan data ke tabel MySQL
    const sql = 'INSERT INTO produk (nama_produk, kategori, harga, stok, satuan, batas_stok) VALUES (?, ?, ?, ?, ?, ?)';
    
    db.query(sql, [nama_produk, kategori, harga, stok, satuan, batas_stok], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.status(201).json({ message: 'Produk berhasil ditambahkan' });
    });
});
// ========================================================
// URL ini dipanggil Flutter saat admin membuka halaman Katalog Produk
app.get('/api/produk', (req, res) => {
    // Mengambil data produk terbaru (ORDER BY id DESC agar yang baru diinput ada di atas)
    const sql = 'SELECT * FROM produk ORDER BY id DESC';
    
    db.query(sql, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.status(200).json(results); // Mengirimkan susunan data barang ke Flutter
    });
});

// Menentukan nomor gerbang/port server, kita pakai angka 3000
const PORT = 3000;
// ========================================================
// JALUR 4: API UBAH DATA PRODUK (PUT METHOD)
// ========================================================
app.put('/api/produk/:id', (req, res) => {
    const { id } = req.params; // Menangkap ID produk dari URL
    const { nama_produk, kategori, harga, stok, satuan, batas_stok } = req.body;
    
    const sql = 'UPDATE produk SET nama_produk=?, kategori=?, harga=?, stok=?, satuan=?, batas_stok=? WHERE id=?';
    
    db.query(sql, [nama_produk, kategori, harga, stok, satuan, batas_stok, id], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.status(200).json({ message: 'Produk berhasil diubah' });
    });
});

// ========================================================
// JALUR 5: API HAPUS DATA PRODUK (DELETE METHOD)
// ========================================================
app.delete('/api/produk/:id', (req, res) => {
    const { id } = req.params;
    
    const sql = 'DELETE FROM produk WHERE id=?';
    
    db.query(sql, [id], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.status(200).json({ message: 'Produk berhasil dihapus' });
    });
});
// ====================================================================
// SPRINT 5: API MANAJEMEN INVENTORI (BARANG MASUK)
// ====================================================================

// 1. API GET: Mengambil daftar riwayat barang masuk (Untuk Halaman UI Figma-mu)
app.get('/api/restock', (req, res) => {
    // Kita gunakan JOIN agar yang tampil di Flutter nanti adalah 'nama_produk', bukan cuma angka 'id_produk'
    const sql = `
        SELECT r.id, r.jumlah_masuk, r.tanggal_masuk, r.supplier, p.nama_produk 
        FROM riwayat_stok r
        JOIN produk p ON r.id_produk = p.id
        ORDER BY r.tanggal_masuk DESC, r.id DESC
    `;
    
    db.query(sql, (err, results) => {
        if (err) {
            console.error('Error mengambil data riwayat:', err);
            return res.status(500).json({ message: 'Gagal mengambil data riwayat' });
        }
        res.status(200).json(results);
    });
});

// 2. API POST: Mencatat barang masuk & Otomatis tambah stok (Logika Magic)
app.post('/api/restock', (req, res) => {
    const { id_produk, jumlah_masuk, tanggal_masuk, supplier } = req.body;

    // Langkah A: Masukkan data ke tabel riwayat_stok sebagai bukti transaksi
    const sqlInsert = 'INSERT INTO riwayat_stok (id_produk, jumlah_masuk, tanggal_masuk, supplier) VALUES (?, ?, ?, ?)';
    
    db.query(sqlInsert, [id_produk, jumlah_masuk, tanggal_masuk, supplier], (err, result) => {
        if (err) {
            console.error('Error insert riwayat:', err);
            return res.status(500).json({ message: 'Gagal mencatat riwayat barang masuk' });
        }

        // Langkah B: Jika insert berhasil, update (tambahkan) jumlah stok di tabel produk
        // Tanda + pada 'stok = stok + ?' inilah yang menjalankan perhitungan matematikanya
        const sqlUpdate = 'UPDATE produk SET stok = stok + ? WHERE id = ?';
        
        db.query(sqlUpdate, [jumlah_masuk, id_produk], (err2, result2) => {
            if (err2) {
                console.error('Error update stok:', err2);
                return res.status(500).json({ message: 'Riwayat tercatat, tapi gagal mengupdate stok katalog' });
            }
            
            res.status(200).json({ 
                message: 'Sukses! Barang masuk dicatat dan stok katalog otomatis bertambah.' 
            });
        });
    });
});
// ====================================================================
// SPRINT 6: API MANAJEMEN INVENTORI (BARANG KELUAR)
// ====================================================================

// 1. API GET: Mengambil daftar riwayat barang keluar
app.get('/api/barang-keluar', (req, res) => {
    const sql = `
        SELECT r.id, r.jumlah_keluar, r.tanggal_keluar, r.keterangan, p.nama_produk 
        FROM riwayat_keluar r
        JOIN produk p ON r.id_produk = p.id
        ORDER BY r.tanggal_keluar DESC, r.id DESC
    `;
    
    db.query(sql, (err, results) => {
        if (err) {
            console.error('Error mengambil data riwayat keluar:', err);
            return res.status(500).json({ message: 'Gagal mengambil data riwayat keluar' });
        }
        res.status(200).json(results);
    });
});

// 2. API POST: Mencatat barang keluar & Otomatis Kurangi Stok
app.post('/api/barang-keluar', (req, res) => {
    const { id_produk, jumlah_keluar, tanggal_keluar, keterangan } = req.body;

    // Langkah A: Masukkan data sebagai bukti transaksi keluar
    const sqlInsert = 'INSERT INTO riwayat_keluar (id_produk, jumlah_keluar, tanggal_keluar, keterangan) VALUES (?, ?, ?, ?)';
    
    db.query(sqlInsert, [id_produk, jumlah_keluar, tanggal_keluar, keterangan], (err, result) => {
        if (err) {
            console.error('Error insert riwayat keluar:', err);
            return res.status(500).json({ message: 'Gagal mencatat riwayat barang keluar' });
        }

        // Langkah B: Kurangi stok di tabel produk
        // Perhatikan tanda minus (-) pada 'stok = stok - ?'
        const sqlUpdate = 'UPDATE produk SET stok = stok - ? WHERE id = ?';
        
        db.query(sqlUpdate, [jumlah_keluar, id_produk], (err2, result2) => {
            if (err2) {
                console.error('Error update stok keluar:', err2);
                return res.status(500).json({ message: 'Riwayat tercatat, tapi gagal mengurangi stok katalog' });
            }
            
            res.status(200).json({ 
                message: 'Sukses! Barang keluar dicatat dan stok katalog otomatis berkurang.' 
            });
        });
    });
});
app.listen(PORT, () => {
    console.log(`Server Backend WARUNG.IN menyala di: http://localhost:${PORT}`);
});