class KategoriModel {
  final int idKategori;
  final String namaKategori;

  KategoriModel({
    required this.idKategori,
    required this.namaKategori,
  });

  factory KategoriModel.fromJson(Map<String, dynamic> json) {
    return KategoriModel(
      idKategori: json['id_kategori'] is String ? int.parse(json['id_kategori']) : json['id_kategori'],
      namaKategori: json['nama_kategori'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_kategori': idKategori,
      'nama_kategori': namaKategori,
    };
  }
}
