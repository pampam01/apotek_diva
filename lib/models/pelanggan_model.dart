class PelangganModel {
  final int idPelanggan;
  final String namaPelanggan;
  final String? noTelepon;
  final String? alamat;

  PelangganModel({
    required this.idPelanggan,
    required this.namaPelanggan,
    this.noTelepon,
    this.alamat,
  });

  factory PelangganModel.fromJson(Map<String, dynamic> json) {
    return PelangganModel(
      idPelanggan: json['id_pelanggan'] is String ? int.parse(json['id_pelanggan']) : json['id_pelanggan'],
      namaPelanggan: json['nama_pelanggan'],
      noTelepon: json['no_telepon'],
      alamat: json['alamat'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pelanggan': idPelanggan,
      'nama_pelanggan': namaPelanggan,
      'no_telepon': noTelepon,
      'alamat': alamat,
    };
  }
}
