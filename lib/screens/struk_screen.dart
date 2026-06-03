import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';

class StrukScreen extends StatelessWidget {
  final Map<String, dynamic> transaksiResult;

  const StrukScreen({super.key, required this.transaksiResult});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Struk Pembayaran'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 100),
              const SizedBox(height: 24),
              const Text(
                'Transaksi Berhasil!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
              ),
              const SizedBox(height: 16),
              Text(
                'No. Faktur: ${transaksiResult['no_faktur']}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 48),
              CustomButton(
                text: 'Cetak Struk',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fitur cetak belum diimplementasikan (Placeholder)')),
                  );
                },
                backgroundColor: Colors.orange,
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Kembali ke Menu Utama',
                onPressed: () {
                  Navigator.pop(context); // Hanya pop StrukScreen untuk kembali ke tab menu utama
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
