import 'detail_transaksi_model.dart';

class TransaksiModel {
  final int idTransaksi;
  final String noFaktur;
  final String tanggalTransaksi;
  final int idUser;
  final String? namaKasir;
  final int idPelanggan;
  final String? namaPelanggan;
  final double totalHarga;
  final double jumlahBayar;
  final double kembalian;
  final List<DetailTransaksiModel>? items;

  TransaksiModel({
    required this.idTransaksi,
    required this.noFaktur,
    required this.tanggalTransaksi,
    required this.idUser,
    this.namaKasir,
    required this.idPelanggan,
    this.namaPelanggan,
    required this.totalHarga,
    required this.jumlahBayar,
    required this.kembalian,
    this.items,
  });

  factory TransaksiModel.fromJson(Map<String, dynamic> json) {
    List<DetailTransaksiModel>? itemsList;
    if (json['items'] != null) {
      itemsList = (json['items'] as List)
          .map((i) => DetailTransaksiModel.fromJson(i))
          .toList();
    }

    return TransaksiModel(
      idTransaksi: json['id_transaksi'] is String ? int.parse(json['id_transaksi']) : json['id_transaksi'],
      noFaktur: json['no_faktur'],
      tanggalTransaksi: json['tanggal_transaksi'],
      idUser: json['id_user'] is String ? int.parse(json['id_user']) : json['id_user'],
      namaKasir: json['nama_kasir'],
      idPelanggan: json['id_pelanggan'] is String ? int.parse(json['id_pelanggan']) : json['id_pelanggan'],
      namaPelanggan: json['nama_pelanggan'],
      totalHarga: json['total_harga'] is String ? double.parse(json['total_harga']) : json['total_harga'].toDouble(),
      jumlahBayar: json['jumlah_bayar'] is String ? double.parse(json['jumlah_bayar']) : json['jumlah_bayar'].toDouble(),
      kembalian: json['kembalian'] is String ? double.parse(json['kembalian']) : json['kembalian'].toDouble(),
      items: itemsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_transaksi': idTransaksi,
      'no_faktur': noFaktur,
      'tanggal_transaksi': tanggalTransaksi,
      'id_user': idUser,
      'nama_kasir': namaKasir,
      'id_pelanggan': idPelanggan,
      'nama_pelanggan': namaPelanggan,
      'total_harga': totalHarga,
      'jumlah_bayar': jumlahBayar,
      'kembalian': kembalian,
      'items': items?.map((i) => i.toJson()).toList(),
    };
  }
}
