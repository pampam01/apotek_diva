import 'package:http/http.dart' as http;

class BypassClient extends http.BaseClient {
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    // Inject Host header so Freehostia knows which domain to route to on the shared IP
    request.headers['Host'] = 'apotek-diva-pp.com';
    request.headers['User-Agent'] =
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
    return _inner.send(request);
  }
}

final httpClient = BypassClient();

class ApiConfig {
  // Use the Shared IP directly so the app works instantly without waiting for DNS propagation
  static const String baseUrl =
      'http://162.210.102.230/php_native_api';

  static const String login = '$baseUrl/auth/login.php';

  static const String getObat = '$baseUrl/obat/get_obat.php';
  static const String detailObat = '$baseUrl/obat/detail_obat.php';
  static const String tambahObat = '$baseUrl/obat/tambah_obat.php';
  static const String editObat = '$baseUrl/obat/edit_obat.php';
  static const String hapusObat = '$baseUrl/obat/hapus_obat.php';

  static const String getPelanggan = '$baseUrl/pelanggan/get_pelanggan.php';
  static const String tambahPelanggan =
      '$baseUrl/pelanggan/tambah_pelanggan.php';

  static const String tambahTransaksi =
      '$baseUrl/transaksi/tambah_transaksi.php';
  static const String getTransaksi = '$baseUrl/transaksi/get_transaksi.php';
  static const String detailTransaksi =
      '$baseUrl/transaksi/detail_transaksi.php';

  static const String dashboard = '$baseUrl/laporan/dashboard.php';
  static const String laporanPenjualan =
      '$baseUrl/laporan/laporan_penjualan.php';
  static const String laporanStok = '$baseUrl/laporan/laporan_stok.php';
}
