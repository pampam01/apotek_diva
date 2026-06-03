import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/transaksi_model.dart';

class TransaksiService {
  Future<List<TransaksiModel>> getTransaksi({String search = ''}) async {
    try {
      final uri = Uri.parse('${ApiConfig.getTransaksi}?search=$search');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return (data['data'] as List)
              .map((json) => TransaksiModel.fromJson(json))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load transaksi');
        }
      } else {
        throw Exception('Failed to connect to server');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<TransaksiModel> getDetailTransaksi(int idTransaksi) async {
    try {
      final uri = Uri.parse('${ApiConfig.detailTransaksi}?id_transaksi=$idTransaksi');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return TransaksiModel.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to load detail');
        }
      } else {
        throw Exception('Failed to connect to server');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>> tambahTransaksi(TransaksiModel transaksi) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.tambahTransaksi),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(transaksi.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return data; // Return no_faktur and id_transaksi
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('Failed to connect to server');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
