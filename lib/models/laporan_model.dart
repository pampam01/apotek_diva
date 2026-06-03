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
  final int idTransaksi;
  final String noFaktur;
  final String tanggalTransaksi;
  final double totalHarga;
  final double jumlahBayar;
  final double kembalian;
  final String kasir;

  LaporanPenjualanModel({
    required this.idTransaksi,
    required this.noFaktur,
    required this.tanggalTransaksi,
    required this.totalHarga,
    required this.jumlahBayar,
    required this.kembalian,
    required this.kasir,
  });

  factory LaporanPenjualanModel.fromJson(Map<String, dynamic> json) {
    return LaporanPenjualanModel(
      idTransaksi: json['id_transaksi'] is String ? int.parse(json['id_transaksi']) : json['id_transaksi'],
      noFaktur: json['no_faktur'],
      tanggalTransaksi: json['tanggal_transaksi'],
      totalHarga: json['total_harga'] is String ? double.parse(json['total_harga']) : json['total_harga'].toDouble(),
      jumlahBayar: json['jumlah_bayar'] is String ? double.parse(json['jumlah_bayar']) : json['jumlah_bayar'].toDouble(),
      kembalian: json['kembalian'] is String ? double.parse(json['kembalian']) : json['kembalian'].toDouble(),
      kasir: json['kasir'],
    );
  }
}
