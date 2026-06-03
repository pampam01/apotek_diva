import 'dart:io';
import 'package:apotek_diva/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/laporan_service.dart';
import '../models/laporan_model.dart';
import '../models/obat_model.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_message.dart';
import '../widgets/simple_bar_chart.dart';
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
          title: const Text('Laporan Apotek'),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(
                icon: Icon(Icons.analytics_outlined),
                text: 'Penjualan',
              ),
              Tab(
                icon: Icon(Icons.inventory_2_outlined),
                text: 'Stok Obat',
              ),
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

  String _selectedPeriod = 'bulanan'; // 'harian', 'mingguan', 'bulanan', 'kustom'
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime.now();

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
      final start = DateFormat('yyyy-MM-dd').format(_startDate);
      final end = DateFormat('yyyy-MM-dd').format(_endDate);

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

  void _setPeriod(String period) {
    setState(() {
      _selectedPeriod = period;
      final now = DateTime.now();
      if (period == 'harian') {
        _startDate = DateTime(now.year, now.month, now.day);
        _endDate = DateTime(now.year, now.month, now.day);
      } else if (period == 'mingguan') {
        _startDate = now.subtract(const Duration(days: 6));
        _endDate = now;
      } else if (period == 'bulanan') {
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = now;
      }
    });
    _loadData();
  }

  Future<void> _selectCustomDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryBlue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedPeriod = 'kustom';
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadData();
    }
  }

  void _simulateExport(String format) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _ExportProgressDialog(
          format: format,
          startDate: _startDate,
          endDate: _endDate,
          list: _list,
          totalPendapatan: _totalPendapatan,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final dateFormat = DateFormat('dd MMM yyyy');

    // Generate dynamic chart data based on filtered list
    final Map<String, double> groupedData = {};
    for (var trx in _list) {
      // Format to dd/MM
      try {
        final parsedDate = DateTime.parse(trx.tanggalTransaksi);
        final key = DateFormat('dd/MM').format(parsedDate);
        groupedData[key] = (groupedData[key] ?? 0) + trx.totalHarga;
      } catch (_) {
        final key = trx.tanggalTransaksi.split(' ')[0];
        groupedData[key] = (groupedData[key] ?? 0) + trx.totalHarga;
      }
    }

    final sortedKeys = groupedData.keys.toList()..sort();
    // Limit to latest 7 points to avoid overcrowding
    final chartLabels = sortedKeys.length > 7 ? sortedKeys.sublist(sortedKeys.length - 7) : sortedKeys;
    final chartValues = chartLabels.map((lbl) => groupedData[lbl]!).toList();
    final double maxVal = chartValues.isEmpty ? 100.0 : chartValues.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      body: Column(
        children: [
          // Filter Period Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppTheme.lightGray,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPeriodButton('Harian', 'harian'),
                    _buildPeriodButton('Mingguan', 'mingguan'),
                    _buildPeriodButton('Bulanan', 'bulanan'),
                    GestureDetector(
                      onTap: _selectCustomDateRange,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedPeriod == 'kustom' ? AppTheme.primaryBlue : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _selectedPeriod == 'kustom' ? AppTheme.primaryBlue : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: _selectedPeriod == 'kustom' ? Colors.white : Colors.black87,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Kustom',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _selectedPeriod == 'kustom' ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Periode: ${dateFormat.format(_startDate)} - ${dateFormat.format(_endDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    InkWell(
                      onTap: _loadData,
                      child: const Row(
                        children: [
                          Icon(Icons.refresh, size: 14, color: AppTheme.primaryBlue),
                          SizedBox(width: 4),
                          Text(
                            'Refresh',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Main View (Loading/Error/Content)
          Expanded(
            child: _isLoading
                ? const LoadingWidget()
                : _error != null
                    ? ErrorMessage(message: _error!, onRetry: _loadData)
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Rekap Pendapatan Card
                              _buildRekapCard(currencyFormatter),

                              // Export Row
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _simulateExport('PDF'),
                                        icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                                        label: const Text('Export PDF'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red.shade700,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _simulateExport('Excel'),
                                        icon: const Icon(Icons.table_view, color: Colors.white),
                                        label: const Text('Export Excel'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.primaryGreen,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Grafik Penjualan Card
                              _buildChartCard(chartLabels, chartValues, maxVal),

                              // List of Transactions
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                                child: Row(
                                  children: [
                                    const Icon(Icons.receipt_long, size: 20, color: AppTheme.primaryBlue),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Daftar Transaksi (${_list.length})',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              if (_list.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 40),
                                  child: Center(
                                    child: Text(
                                      'Tidak ada transaksi pada periode ini',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                )
                              else
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: _list.length,
                                  itemBuilder: (context, index) {
                                    final item = _list[index];
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      elevation: 1,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
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
                                                size: 22,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item.noFaktur,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '${item.tanggalTransaksi} • Kasir: ${item.kasir}',
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 11,
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
                                                    fontSize: 15,
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
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return GestureDetector(
      onTap: () => _setPeriod(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildRekapCard(NumberFormat currencyFormatter) {
    return Container(
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rekap Pendapatan (Periode Ini)',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
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
    );
  }

  Widget _buildChartCard(List<String> labels, List<double> values, double maxVal) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.bar_chart, color: AppTheme.primaryBlue, size: 20),
                SizedBox(width: 8),
                Text(
                  'Grafik Statistik Penjualan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (values.isEmpty)
              const SizedBox(
                height: 150,
                child: Center(
                  child: Text(
                    'Tidak ada data penjualan untuk grafik',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              )
            else
              SizedBox(
                height: 180,
                child: SimpleBarChart(
                  data: values,
                  labels: labels,
                  maxY: maxVal > 0 ? maxVal : 100,
                ),
              ),
          ],
        ),
      ),
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
  List<ObatModel> _allList = [];
  List<ObatModel> _filteredList = [];
  bool _isLoading = true;
  String? _error;

  String _stockFilter = 'all'; // 'all', 'low'
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Get all stocks from backend
      final data = await _laporanService.getLaporanStok(all: true);
      if (mounted) {
        setState(() {
          _allList = data;
          _isLoading = false;
        });
        _applyFilters();
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

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    List<ObatModel> temp = List.from(_allList);

    // Apply low stock filter
    if (_stockFilter == 'low') {
      temp = temp.where((obat) => obat.stok < 10).toList();
    }

    // Apply search query
    if (query.isNotEmpty) {
      temp = temp.where((obat) {
        return obat.namaObat.toLowerCase().contains(query) ||
            obat.kodeObat.toLowerCase().contains(query);
      }).toList();
    }

    setState(() {
      _filteredList = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const LoadingWidget();
    if (_error != null) {
      return ErrorMessage(message: _error!, onRetry: _loadData);
    }

    // Calculate summaries
    final totalJenis = _allList.length;
    final totalUnit = _allList.fold<int>(0, (sum, o) => sum + o.stok);
    final totalStokKritis = _allList.where((o) => o.stok < 10).length;

    return Scaffold(
      body: Column(
        children: [
          // Stock Summary Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(20),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('Total Obat', '$totalJenis', Icons.medication, AppTheme.primaryBlue),
                _buildDivider(),
                _buildSummaryItem('Total Stok', '$totalUnit Pcs', Icons.inventory_2, AppTheme.primaryGreen),
                _buildDivider(),
                _buildSummaryItem('Stok Kritis', '$totalStokKritis', Icons.warning_amber, AppTheme.errorRed),
              ],
            ),
          ),

          // Filters Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Semua Obat'),
                  selected: _stockFilter == 'all',
                  selectedColor: AppTheme.primaryBlue.withAlpha(40),
                  labelStyle: TextStyle(
                    color: _stockFilter == 'all' ? AppTheme.primaryBlue : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _stockFilter = 'all');
                      _applyFilters();
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Stok Menipis (< 10)'),
                  selected: _stockFilter == 'low',
                  selectedColor: AppTheme.errorRed.withAlpha(40),
                  labelStyle: TextStyle(
                    color: _stockFilter == 'low' ? AppTheme.errorRed : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _stockFilter = 'low');
                      _applyFilters();
                    }
                  },
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari nama atau kode obat...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _applyFilters();
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                filled: true,
                fillColor: AppTheme.lightGray,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // List of Drugs
          Expanded(
            child: _filteredList.isEmpty
                ? const Center(child: Text('Tidak ada obat ditemukan'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredList.length,
                    itemBuilder: (context, index) {
                      final obat = _filteredList[index];
                      final isLowStock = obat.stok < 10;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.grey.shade300,
    );
  }
}

class _ExportProgressDialog extends StatefulWidget {
  final String format;
  final DateTime startDate;
  final DateTime endDate;
  final List<LaporanPenjualanModel> list;
  final double totalPendapatan;

  const _ExportProgressDialog({
    required this.format,
    required this.startDate,
    required this.endDate,
    required this.list,
    required this.totalPendapatan,
  });

  @override
  State<_ExportProgressDialog> createState() => _ExportProgressDialogState();
}

class _ExportProgressDialogState extends State<_ExportProgressDialog> {
  int _step = 0;
  String _statusMessage = 'Menghubungkan ke database...';
  bool _isSuccess = false;
  late String _fileName;
  String? _filePath;

  @override
  void initState() {
    super.initState();
    final startStr = DateFormat('yyyyMMdd').format(widget.startDate);
    final endStr = DateFormat('yyyyMMdd').format(widget.endDate);
    _fileName = 'Laporan_Penjualan_${startStr}_$endStr.${widget.format == 'PDF' ? 'html' : 'csv'}';
    _runSimulation();
  }

  void _runSimulation() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _step = 1;
      _statusMessage = 'Mengambil data transaksi dan hitung pendapatan...';
    });

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _step = 2;
      _statusMessage = 'Menyusun dokumen dan tata letak ${_fileName}...';
    });

    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$_fileName');
      final dateRangeStr = '${DateFormat('dd MMM yyyy').format(widget.startDate)} - ${DateFormat('dd MMM yyyy').format(widget.endDate)}';

      if (widget.format == 'Excel') {
        final buffer = StringBuffer();
        buffer.writeln('LAPORAN PENJUALAN APOTEK DIVA');
        buffer.writeln('Periode: $dateRangeStr');
        buffer.writeln('Total Pendapatan: Rp ${widget.totalPendapatan.toStringAsFixed(0)}');
        buffer.writeln();
        buffer.writeln('No Faktur;Tanggal Transaksi;Kasir;Total Pemasukan');
        
        for (var item in widget.list) {
          buffer.writeln('${item.noFaktur};${item.tanggalTransaksi};${item.kasir};${item.totalHarga.toStringAsFixed(0)}');
        }
        await file.writeAsString(buffer.toString());
      } else {
        // PDF Simulation via HTML (extremely robust for mobile printers and browsers)
        final buffer = StringBuffer();
        buffer.writeln('''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Laporan Penjualan - Apotek Diva</title>
  <style>
    body { font-family: sans-serif; margin: 30px; color: #333; }
    h1 { color: #0D63B7; margin-bottom: 5px; }
    .meta { color: #666; margin-bottom: 20px; font-size: 14px; }
    table { width: 100%; border-collapse: collapse; margin-top: 20px; }
    th, td { border: 1px solid #ddd; padding: 10px; text-align: left; }
    th { background-color: #0D63B7; color: white; }
    tr:nth-child(even) { background-color: #f9f9f9; }
    .total-row { font-weight: bold; background-color: #e3f2fd !important; }
    .text-right { text-align: right; }
  </style>
</head>
<body>
  <h1>Apotek Diva</h1>
  <div class="meta">
    <h2>Laporan Penjualan</h2>
    <p><strong>Periode:</strong> $dateRangeStr</p>
    <p><strong>Total Pemasukan:</strong> Rp ${NumberFormat('#,###', 'id_ID').format(widget.totalPendapatan)}</p>
  </div>
  <table>
    <thead>
      <tr>
        <th>No.</th>
        <th>No. Faktur</th>
        <th>Tanggal Transaksi</th>
        <th>Kasir</th>
        <th class="text-right">Total Transaksi</th>
      </tr>
    </thead>
    <tbody>
''');

        for (int i = 0; i < widget.list.length; i++) {
          final item = widget.list[i];
          final formattedTotal = NumberFormat('#,###', 'id_ID').format(item.totalHarga);
          buffer.writeln('''
      <tr>
        <td>${i + 1}</td>
        <td>${item.noFaktur}</td>
        <td>${item.tanggalTransaksi}</td>
        <td>${item.kasir}</td>
        <td class="text-right">Rp $formattedTotal</td>
      </tr>
''');
        }

        final formattedGrandTotal = NumberFormat('#,###', 'id_ID').format(widget.totalPendapatan);
        buffer.writeln('''
      <tr class="total-row">
        <td colspan="4" class="text-right">Total Pendapatan</td>
        <td class="text-right">Rp $formattedGrandTotal</td>
      </tr>
    </tbody>
  </table>
</body>
</html>
''');
        await file.writeAsString(buffer.toString());
      }
      
      _filePath = file.path;
    } catch (e) {
      debugPrint('Export file creation failed: $e');
      setState(() {
        _statusMessage = 'Gagal membuat file: $e';
        _filePath = null;
      });
      return;
    }

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _step = 3;
      _statusMessage = 'Menyimpan dan mempersiapkan berkas ekspor...';
    });

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _isSuccess = true;
      _statusMessage = 'Berkas laporan siap dibagikan / diunduh!';
    });
  }

  void _shareFile() async {
    if (_filePath != null) {
      await Share.shareXFiles([XFile(_filePath!)], text: 'Laporan Penjualan Apotek Diva');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menemukan berkas ekspor')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            widget.format == 'PDF' ? Icons.picture_as_pdf : Icons.table_view,
            color: widget.format == 'PDF' ? Colors.red.shade700 : AppTheme.primaryGreen,
          ),
          const SizedBox(width: 8),
          Text('Ekspor Laporan ${widget.format}'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          if (!_isSuccess)
            Column(
              children: [
                const SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _statusMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            )
          else
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ekspor Berhasil!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _fileName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _statusMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _shareFile,
                  icon: const Icon(Icons.share, color: Colors.white),
                  label: const Text('Simpan / Bagikan ke HP'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            _isSuccess ? 'Tutup' : 'Batalkan',
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
