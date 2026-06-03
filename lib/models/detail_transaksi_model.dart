class DetailTransaksiModel {
  final int idDetail;
  final int idTransaksi;
  final int idObat;
  final String? namaObat;
  final String? kodeObat;
  final int jumlah;
  final double hargaSatuan;
  final double subtotal;

  DetailTransaksiModel({
    required this.idDetail,
    required this.idTransaksi,
    required this.idObat,
    this.namaObat,
    this.kodeObat,
    required this.jumlah,
    required this.hargaSatuan,
    required this.subtotal,
  });

  factory DetailTransaksiModel.fromJson(Map<String, dynamic> json) {
    return DetailTransaksiModel(
      idDetail: json['id_detail'] is String ? int.parse(json['id_detail']) : json['id_detail'],
      idTransaksi: json['id_transaksi'] is String ? int.parse(json['id_transaksi']) : json['id_transaksi'],
      idObat: json['id_obat'] is String ? int.parse(json['id_obat']) : json['id_obat'],
      namaObat: json['nama_obat'],
      kodeObat: json['kode_obat'],
      jumlah: json['jumlah'] is String ? int.parse(json['jumlah']) : json['jumlah'],
      hargaSatuan: json['harga_satuan'] is String ? double.parse(json['harga_satuan']) : json['harga_satuan'].toDouble(),
      subtotal: json['subtotal'] is String ? double.parse(json['subtotal']) : json['subtotal'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_detail': idDetail,
      'id_transaksi': idTransaksi,
      'id_obat': idObat,
      'nama_obat': namaObat,
      'kode_obat': kodeObat,
      'jumlah': jumlah,
      'harga_satuan': hargaSatuan,
      'subtotal': subtotal,
    };
  }
}
