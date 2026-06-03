import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/obat_model.dart';

class ObatService {
  Future<List<ObatModel>> getObat({String search = ''}) async {
    try {
      final uri = Uri.parse('${ApiConfig.getObat}?search=$search');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return (data['data'] as List)
              .map((json) => ObatModel.fromJson(json))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load obat');
        }
      } else {
        throw Exception('Failed to connect to server');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> tambahObat(ObatModel obat) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.tambahObat),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(obat.toJson()),
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

  Future<void> updateObat(ObatModel obat) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.editObat),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(obat.toJson()),
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

  Future<void> hapusObat(int idObat) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.hapusObat),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_obat': idObat}),
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
