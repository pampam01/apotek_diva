class ObatModel {
  final int idObat;
  final String kodeObat;
  final String namaObat;
  final int idKategori;
  final String? namaKategori;
  final double hargaBeli;
  final double hargaJual;
  final int stok;
  final String satuan;
  final String tanggalKadaluarsa;
  final String? keterangan;

  ObatModel({
    required this.idObat,
    required this.kodeObat,
    required this.namaObat,
    required this.idKategori,
    this.namaKategori,
    required this.hargaBeli,
    required this.hargaJual,
    required this.stok,
    required this.satuan,
    required this.tanggalKadaluarsa,
    this.keterangan,
  });

  factory ObatModel.fromJson(Map<String, dynamic> json) {
    return ObatModel(
      idObat: json['id_obat'] is String ? int.parse(json['id_obat']) : json['id_obat'],
      kodeObat: json['kode_obat'],
      namaObat: json['nama_obat'],
      idKategori: json['id_kategori'] is String ? int.parse(json['id_kategori']) : json['id_kategori'],
      namaKategori: json['nama_kategori'],
      hargaBeli: json['harga_beli'] is String ? double.parse(json['harga_beli']) : json['harga_beli'].toDouble(),
      hargaJual: json['harga_jual'] is String ? double.parse(json['harga_jual']) : json['harga_jual'].toDouble(),
      stok: json['stok'] is String ? int.parse(json['stok']) : json['stok'],
      satuan: json['satuan'],
      tanggalKadaluarsa: json['tanggal_kadaluarsa'],
      keterangan: json['keterangan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_obat': idObat,
      'kode_obat': kodeObat,
      'nama_obat': namaObat,
      'id_kategori': idKategori,
      'harga_beli': hargaBeli,
      'harga_jual': hargaJual,
      'stok': stok,
      'satuan': satuan,
      'tanggal_kadaluarsa': tanggalKadaluarsa,
      'keterangan': keterangan,
    };
  }
}
