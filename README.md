# Aplikasi Manajemen Stok Obat Apotek Diva

Aplikasi Flutter untuk manajemen stok obat dan transaksi kasir (Point of Sale), didukung oleh backend PHP Native dan MySQL.

## Fitur
1. **Autentikasi**: Login Kasir dan Admin.
2. **Dashboard**: Ringkasan penjualan, total obat, peringatan stok menipis, dan grafik sederhana.
3. **Manajemen Stok Obat**: 
   - Melihat daftar obat.
   - Menambah, mengedit, dan menghapus data obat.
   - Peringatan warna merah untuk stok kurang dari 10.
4. **Transaksi (POS)**:
   - Pencarian obat.
   - Menambahkan obat ke keranjang.
   - Perhitungan total dan kembalian otomatis.
   - Halaman struk sukses.
5. **Laporan**:
   - Laporan Penjualan (berdasarkan tanggal).
   - Laporan Stok (semua obat atau hanya stok menipis).

## Persyaratan
- Flutter SDK >= 3.8.1
- Web Server (Apache/Nginx) dengan PHP >= 7.4
- MySQL / MariaDB

## Instalasi Backend (PHP & MySQL)
1. Buat database baru di MySQL, misalnya `apotek_diva`.
2. Import file `database/apotek_diva.sql` ke dalam database tersebut.
3. Pindahkan folder `php_native_api/` ke dalam folder root web server Anda (misal `htdocs` untuk XAMPP).
4. Buka file `php_native_api/config/koneksi.php` dan sesuaikan `$host`, `$user`, `$pass`, dan `$db` dengan konfigurasi server database Anda (atau konfigurasi InfinityFree Anda).

## Instalasi Frontend (Flutter)
1. Buka file `lib/config/api_config.dart`.
2. Ubah `baseUrl` ke URL tempat Anda meng-host backend PHP. 
   - *Catatan: Untuk Android Emulator yang terhubung ke localhost XAMPP, gunakan `http://10.0.2.2/php_native_api`.*
3. Jalankan perintah berikut di terminal:
   ```bash
   flutter pub get
   ```
4. Jalankan aplikasi:
   ```bash
   flutter run
   ```

## Akun Default
- **Username**: admin
- **Password**: admin123
- **Role**: Admin

- **Username**: kasir1
- **Password**: kasir123
- **Role**: Kasir
