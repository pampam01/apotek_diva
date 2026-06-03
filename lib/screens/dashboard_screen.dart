import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/laporan_model.dart';
import '../services/laporan_service.dart';
import '../widgets/info_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_message.dart';
import '../widgets/simple_bar_chart.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _laporanService = LaporanService();
  DashboardModel? _dashboardData;
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
      final data = await _laporanService.getDashboard();
      if (mounted) {
        setState(() {
          _dashboardData = data;
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
    if (_isLoading) {
      return const Scaffold(body: LoadingWidget());
    }

    if (_error != null) {
      return Scaffold(body: ErrorMessage(message: _error!, onRetry: _loadData));
    }

    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ringkasan Hari Ini',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              InfoCard(
                title: 'Total Penjualan',
                value: currencyFormatter.format(_dashboardData?.totalPenjualanHariIni ?? 0),
                icon: Icons.monetization_on,
                color: AppTheme.primaryBlue,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InfoCard(
                      title: 'Total Jenis Obat',
                      value: '${_dashboardData?.totalObat ?? 0}',
                      icon: Icons.medication,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InfoCard(
                      title: 'Stok Menipis',
                      value: '${_dashboardData?.obatHampirHabis ?? 0}',
                      icon: Icons.warning_amber,
                      color: AppTheme.errorRed,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              InfoCard(
                title: 'Total Transaksi (Bulan Ini)',
                value: '${_dashboardData?.totalTransaksiBulanIni ?? 0}',
                icon: Icons.receipt,
                color: Colors.orange,
              ),
              const SizedBox(height: 24),
              Text(
                'Grafik Penjualan (Contoh 7 Hari)',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              const SizedBox(
                height: 200,
                child: SimpleBarChart(
                  data: [120000, 250000, 100000, 450000, 300000, 150000, 500000],
                  labels: ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'],
                  maxY: 500000,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
