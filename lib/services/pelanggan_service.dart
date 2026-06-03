import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/pelanggan_model.dart';

class PelangganService {
  Future<List<PelangganModel>> getPelanggan({String search = ''}) async {
    try {
      final uri = Uri.parse('${ApiConfig.getPelanggan}?search=$search');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return (data['data'] as List)
              .map((json) => PelangganModel.fromJson(json))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load pelanggan');
        }
      } else {
        throw Exception('Failed to connect to server');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> tambahPelanggan(PelangganModel pelanggan) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.tambahPelanggan),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(pelanggan.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] != 'success') {
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
