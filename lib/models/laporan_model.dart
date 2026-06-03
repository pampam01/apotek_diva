class DashboardModel {
  final double totalPenjualanHariIni;
  final int totalObat;
  final int obatHampirHabis;
  final int totalTransaksiBulanIni;

  DashboardModel({
    required this.totalPenjualanHariIni,
    required this.totalObat,
    required this.obatHampirHabis,
    required this.totalTransaksiBulanIni,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalPenjualanHariIni: json['total_penjualan_hari_ini'] is String ? double.parse(json['total_penjualan_hari_ini']) : json['total_penjualan_hari_ini'].toDouble(),
      totalObat: json['total_obat'] is String ? int.parse(json['total_obat']) : json['total_obat'],
      obatHampirHabis: json['obat_hampir_habis'] is String ? int.parse(json['obat_hampir_habis']) : json['obat_hampir_habis'],
      totalTransaksiBulanIni: json['total_transaksi_bulan_ini'] is String ? int.parse(json['total_transaksi_bulan_ini']) : json['total_transaksi_bulan_ini'],
    );
  }
}

class LaporanPenjualanModel {
  final String noFaktur;
  final String tanggalTransaksi;
  final double totalHarga;
  final String kasir;

  LaporanPenjualanModel({
    required this.noFaktur,
    required this.tanggalTransaksi,
    required this.totalHarga,
    required this.kasir,
  });

  factory LaporanPenjualanModel.fromJson(Map<String, dynamic> json) {
    return LaporanPenjualanModel(
      noFaktur: json['no_faktur'],
      tanggalTransaksi: json['tanggal_transaksi'],
      totalHarga: json['total_harga'] is String ? double.parse(json['total_harga']) : json['total_harga'].toDouble(),
      kasir: json['kasir'],
    );
  }
}
