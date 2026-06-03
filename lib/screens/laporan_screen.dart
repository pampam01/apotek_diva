import 'package:apotek_diva/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/laporan_service.dart';
import '../models/laporan_model.dart';
import '../models/obat_model.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_message.dart';
import '../services/transaksi_service.dart';
import 'struk_screen.dart';

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
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Penjualan'),
              Tab(text: 'Stok Obat'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [LaporanPenjualanView(), LaporanStokView()],
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

  void _reprintStruk(LaporanPenjualanModel item) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    try {
      final detail = await TransaksiService().getDetailTransaksi(item.idTransaksi);
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StrukScreen(
              noFaktur: detail.noFaktur,
              items: detail.items ?? [],
              totalHarga: detail.totalHarga,
              jumlahBayar: detail.jumlahBayar,
              kembalian: detail.kembalian,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil detail transaksi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const LoadingWidget();
    if (_error != null) {
      return ErrorMessage(message: _error!, onRetry: _loadData);
    }

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryBlue, Color(0xFF1E88E5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withAlpha(50),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Pendapatan (Bulan Ini)',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormatter.format(_totalPendapatan),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(50),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.monetization_on,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _list.isEmpty
              ? const Center(child: Text('Tidak ada data penjualan bulan ini'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _list.length,
                  itemBuilder: (context, index) {
                    final item = _list[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withAlpha(25),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.receipt_long,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.noFaktur,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item.tanggalTransaksi} • Kasir: ${item.kasir}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  currencyFormatter.format(item.totalHarga),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryGreen,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                IconButton(
                                  icon: const Icon(Icons.print, color: Colors.orange, size: 20),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () => _reprintStruk(item),
                                  tooltip: 'Cetak Ulang Struk',
                                ),
                              ],
                            ),
                          ],
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
    if (_error != null)
      return ErrorMessage(message: _error!, onRetry: _loadData);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Card(
            elevation: 0,
            color: AppTheme.lightGray,
            child: SwitchListTile(
              title: const Text(
                'Tampilkan Semua Obat',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
              subtitle: const Text(
                'Menampilkan seluruh katalog obat jika diaktifkan',
              ),
              value: _showAll,
              activeColor: AppTheme.primaryBlue,
              onChanged: (val) {
                setState(() => _showAll = val);
                _loadData();
              },
            ),
          ),
        ),
        Expanded(
          child: _list.isEmpty
              ? const Center(child: Text('Tidak ada obat dengan stok menipis'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _list.length,
                  itemBuilder: (context, index) {
                    final obat = _list[index];
                    final isLowStock = obat.stok < 10;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isLowStock
                                    ? AppTheme.errorRed.withAlpha(25)
                                    : AppTheme.primaryGreen.withAlpha(25),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.medication,
                                color: isLowStock
                                    ? AppTheme.errorRed
                                    : AppTheme.primaryGreen,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    obat.namaObat,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Kategori: ${obat.namaKategori ?? '-'} • Kode: ${obat.kodeObat}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isLowStock
                                    ? AppTheme.errorRed.withAlpha(25)
                                    : AppTheme.primaryGreen.withAlpha(25),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${obat.stok} ${obat.satuan}',
                                style: TextStyle(
                                  color: isLowStock
                                      ? AppTheme.errorRed
                                      : AppTheme.primaryGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
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
