import 'dart:convert';
import '../config/api_config.dart';
import '../models/laporan_model.dart';
import '../models/obat_model.dart';

class LaporanService {
  Future<DashboardModel> getDashboard() async {
    try {
      final response = await httpClient.get(Uri.parse(ApiConfig.dashboard));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return DashboardModel.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to load dashboard');
        }
      } else {
        throw Exception('Failed to connect to server');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>> getLaporanPenjualan(String startDate, String endDate) async {
    try {
      final uri = Uri.parse('${ApiConfig.laporanPenjualan}?start_date=$startDate&end_date=$endDate');
      final response = await httpClient.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          List<LaporanPenjualanModel> list = (data['data']['list'] as List)
              .map((json) => LaporanPenjualanModel.fromJson(json))
              .toList();
          return {
            'list': list,
            'total_pendapatan': data['data']['total_pendapatan'] is String ? double.parse(data['data']['total_pendapatan']) : data['data']['total_pendapatan'].toDouble(),
          };
        } else {
          throw Exception(data['message'] ?? 'Failed to load laporan penjualan');
        }
      } else {
        throw Exception('Failed to connect to server');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<ObatModel>> getLaporanStok({bool all = false}) async {
    try {
      final uri = Uri.parse('${ApiConfig.laporanStok}?all=${all ? 1 : 0}');
      final response = await httpClient.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return (data['data'] as List)
              .map((json) => ObatModel.fromJson(json))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load laporan stok');
        }
      } else {
        throw Exception('Failed to connect to server');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
