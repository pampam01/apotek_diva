import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/stok_obat_screen.dart';
import '../screens/transaksi_screen.dart';
import '../screens/laporan_screen.dart';
import '../theme/app_theme.dart';
import '../models/user_model.dart';

class BottomNav extends StatefulWidget {
  final UserModel user;
  
  const BottomNav({super.key, required this.user});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [];
  final List<BottomNavigationBarItem> _navItems = [];

  @override
  void initState() {
    super.initState();
    _buildMenu();
  }

  void _buildMenu() {
    final role = widget.user.role.toLowerCase();
    
    // Dashboard (Admin & Kasir)
    _screens.add(const DashboardScreen());
    _navItems.add(const BottomNavigationBarItem(
      icon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ));

    // Stok Obat (Hanya Admin)
    if (role == 'admin') {
      _screens.add(const StokObatScreen());
      _navItems.add(const BottomNavigationBarItem(
        icon: Icon(Icons.inventory),
        label: 'Stok',
      ));
    }

    // Transaksi POS (Admin & Kasir)
    _screens.add(const TransaksiScreen());
    _navItems.add(const BottomNavigationBarItem(
      icon: Icon(Icons.point_of_sale),
      label: 'Transaksi',
    ));

    // Laporan Keuangan (Hanya Admin)
    if (role == 'admin') {
      _screens.add(const LaporanScreen());
      _navItems.add(const BottomNavigationBarItem(
        icon: Icon(Icons.bar_chart),
        label: 'Laporan',
      ));
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getActiveScreen() {
    final role = widget.user.role.toLowerCase();
    if (role == 'admin') {
      switch (_selectedIndex) {
        case 0: return const DashboardScreen();
        case 1: return const StokObatScreen();
        case 2: return const TransaksiScreen();
        case 3: return const LaporanScreen();
      }
    } else {
      switch (_selectedIndex) {
        case 0: return const DashboardScreen();
        case 1: return const TransaksiScreen();
      }
    }
    return const DashboardScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getActiveScreen(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppTheme.primaryBlue,
        unselectedItemColor: AppTheme.textSecondary,
        items: _navItems,
      ),
    );
  }
}
