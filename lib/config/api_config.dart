class ApiConfig {
  static const String baseUrl = 'http://localhost:8000/php_native_api'; // Set to localhost:8000/php_native_api for adb reverse tcp:8000 tcp:8000

  static const String login = '$baseUrl/auth/login.php';

  static const String getObat = '$baseUrl/obat/get_obat.php';
  static const String detailObat = '$baseUrl/obat/detail_obat.php';
  static const String tambahObat = '$baseUrl/obat/tambah_obat.php';
  static const String editObat = '$baseUrl/obat/edit_obat.php';
  static const String hapusObat = '$baseUrl/obat/hapus_obat.php';

  static const String getPelanggan = '$baseUrl/pelanggan/get_pelanggan.php';
  static const String tambahPelanggan = '$baseUrl/pelanggan/tambah_pelanggan.php';

  static const String tambahTransaksi = '$baseUrl/transaksi/tambah_transaksi.php';
  static const String getTransaksi = '$baseUrl/transaksi/get_transaksi.php';
  static const String detailTransaksi = '$baseUrl/transaksi/detail_transaksi.php';

  static const String dashboard = '$baseUrl/laporan/dashboard.php';
  static const String laporanPenjualan = '$baseUrl/laporan/laporan_penjualan.php';
  static const String laporanStok = '$baseUrl/laporan/laporan_stok.php';
}
