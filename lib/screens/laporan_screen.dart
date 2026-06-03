import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/laporan_service.dart';
import '../models/laporan_model.dart';
import '../models/obat_model.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_message.dart';

class LaporanScreen extends StatelessWidget {
  const LaporanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Laporan'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Penjualan'),
              Tab(text: 'Stok Obat'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            LaporanPenjualanView(),
            LaporanStokView(),
          ],
        ),
      ),
    );
  }
}

class LaporanPenjualanView extends StatefulWidget {
  const LaporanPenjualanView({super.key});

  @override
  State<LaporanPenjualanView> createState() => _LaporanPenjualanViewState();
}

class _LaporanPenjualanViewState extends State<LaporanPenjualanView> {
  final _laporanService = LaporanService();
  List<LaporanPenjualanModel> _list = [];
  double _totalPendapatan = 0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, 1).toString().split(' ')[0];
      final end = now.toString().split(' ')[0];
      
      final data = await _laporanService.getLaporanPenjualan(start, end);
      if (mounted) {
        setState(() {
          _list = data['list'];
          _totalPendapatan = data['total_pendapatan'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const LoadingWidget();
    if (_error != null) return ErrorMessage(message: _error!, onRetry: _loadData);

    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Pendapatan (Bulan Ini):', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                currencyFormatter.format(_totalPendapatan),
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _list.length,
            itemBuilder: (context, index) {
              final item = _list[index];
              return ListTile(
                title: Text(item.noFaktur),
                subtitle: Text('${item.tanggalTransaksi} - Kasir: ${item.kasir}'),
                trailing: Text(currencyFormatter.format(item.totalHarga), style: const TextStyle(fontWeight: FontWeight.bold)),
              );
            },
          ),
        ),
      ],
    );
  }
}

class LaporanStokView extends StatefulWidget {
  const LaporanStokView({super.key});

  @override
  State<LaporanStokView> createState() => _LaporanStokViewState();
}

class _LaporanStokViewState extends State<LaporanStokView> {
  final _laporanService = LaporanService();
  List<ObatModel> _list = [];
  bool _isLoading = true;
  String? _error;
  bool _showAll = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _laporanService.getLaporanStok(all: _showAll);
      if (mounted) {
        setState(() {
          _list = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const LoadingWidget();
    if (_error != null) return ErrorMessage(message: _error!, onRetry: _loadData);

    return Column(
      children: [
        SwitchListTile(
          title: const Text('Tampilkan Semua Obat (Tidak Hanya Stok Menipis)'),
          value: _showAll,
          onChanged: (val) {
            setState(() => _showAll = val);
            _loadData();
          },
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _list.length,
            itemBuilder: (context, index) {
              final obat = _list[index];
              return ListTile(
                title: Text(obat.namaObat),
                subtitle: Text('Kategori: ${obat.namaKategori ?? '-'}'),
                trailing: Text(
                  'Stok: ${obat.stok} ${obat.satuan}',
                  style: TextStyle(
                    color: obat.stok < 10 ? Colors.red : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
