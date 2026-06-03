import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/detail_transaksi_model.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';

class StrukScreen extends StatelessWidget {
  final String noFaktur;
  final List<DetailTransaksiModel> items;
  final double totalHarga;
  final double jumlahBayar;
  final double kembalian;

  const StrukScreen({
    super.key,
    required this.noFaktur,
    required this.items,
    required this.totalHarga,
    required this.jumlahBayar,
    required this.kembalian,
  });

  void _simulasikanCetak(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Menghubungkan ke Printer Bluetooth...'),
            ],
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        Navigator.pop(context); // Tutup dialog loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.print, color: Colors.white),
                SizedBox(width: 8),
                Text('Struk Berhasil Dicetak ke Printer Thermal!'),
              ],
            ),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormatter = DateFormat('dd-MM-yyyy HH:mm');
    final tglSelesai = dateFormatter.format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Struk'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Simbol Centang Sukses
            const Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 64),
            const SizedBox(height: 12),
            const Text(
              'Transaksi Berhasil!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
            ),
            const SizedBox(height: 24),

            // Tampilan Kertas Struk Thermal
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(8),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Toko
                  const Center(
                    child: Text(
                      'APOTEK DIVA',
                      style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  const Center(
                    child: Text(
                      'Jl. Raya Kampus, Kota Diva',
                      style: TextStyle(fontFamily: 'Courier', fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  const Center(
                    child: Text(
                      'Telp: (021) 9876543',
                      style: TextStyle(fontFamily: 'Courier', fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '------------------------------------------',
                    style: TextStyle(fontFamily: 'Courier', color: Colors.grey.shade400),
                    textAlign: TextAlign.center,
                  ),

                  // Info Faktur
                  Text(
                    'Faktur   : $noFaktur',
                    style: const TextStyle(fontFamily: 'Courier', fontSize: 13),
                  ),
                  Text(
                    'Tanggal  : $tglSelesai',
                    style: const TextStyle(fontFamily: 'Courier', fontSize: 13),
                  ),
                  Text(
                    'Kasir    : Admin',
                    style: const TextStyle(fontFamily: 'Courier', fontSize: 13),
                  ),
                  Text(
                    '------------------------------------------',
                    style: TextStyle(fontFamily: 'Courier', color: Colors.grey.shade400),
                    textAlign: TextAlign.center,
                  ),

                  // Daftar Item Obat
                  const SizedBox(height: 4),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${item.namaObat} (x${item.jumlah})',
                                style: const TextStyle(fontFamily: 'Courier', fontSize: 13),
                              ),
                            ),
                            Text(
                              currencyFormatter.format(item.subtotal),
                              style: const TextStyle(fontFamily: 'Courier', fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '------------------------------------------',
                    style: TextStyle(fontFamily: 'Courier', color: Colors.grey.shade400),
                    textAlign: TextAlign.center,
                  ),

                  // Rincian Pembayaran
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TOTAL HARGA', style: TextStyle(fontFamily: 'Courier', fontSize: 13, fontWeight: FontWeight.bold)),
                      Text(currencyFormatter.format(totalHarga), style: const TextStyle(fontFamily: 'Courier', fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('BAYAR', style: TextStyle(fontFamily: 'Courier', fontSize: 13)),
                      Text(currencyFormatter.format(jumlahBayar), style: const TextStyle(fontFamily: 'Courier', fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('KEMBALIAN', style: TextStyle(fontFamily: 'Courier', fontSize: 13, fontWeight: FontWeight.bold)),
                      Text(currencyFormatter.format(kembalian), style: const TextStyle(fontFamily: 'Courier', fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Text(
                    '==========================================',
                    style: TextStyle(fontFamily: 'Courier', color: Colors.grey.shade400),
                    textAlign: TextAlign.center,
                  ),

                  // Footer Struk
                  const Center(
                    child: Text(
                      'Terima Kasih atas Kunjungan Anda',
                      style: TextStyle(fontFamily: 'Courier', fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                  ),
                  const Center(
                    child: Text(
                      'Semoga Lekas Sembuh',
                      style: TextStyle(fontFamily: 'Courier', fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),

            // Tombol Cetak & Selesai
            CustomButton(
              text: 'Cetak Struk',
              icon: Icons.print,
              onPressed: () => _simulasikanCetak(context),
              backgroundColor: Colors.orange,
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Kembali ke Menu Utama',
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
