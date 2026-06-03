import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/obat_model.dart';
import '../models/transaksi_model.dart';
import '../models/detail_transaksi_model.dart';
import '../services/obat_service.dart';
import '../services/transaksi_service.dart';
import '../widgets/custom_button.dart';
import 'struk_screen.dart';
import '../theme/app_theme.dart';

class TransaksiScreen extends StatefulWidget {
  const TransaksiScreen({super.key});

  @override
  State<TransaksiScreen> createState() => _TransaksiScreenState();
}

class _TransaksiScreenState extends State<TransaksiScreen> {
  final _obatService = ObatService();
  final _transaksiService = TransaksiService();
  final _searchController = TextEditingController();
  final _bayarController = TextEditingController();

  List<ObatModel> _searchResults = [];
  final List<DetailTransaksiModel> _cart = [];
  final Map<int, int> _obatStokMap = {};
  bool _isLoadingSearch = false;
  bool _isProcessing = false;

  final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _searchObat(''); // Load all obat by default
  }

  void _searchObat(String query) async {
    setState(() => _isLoadingSearch = true);
    try {
      final results = await _obatService.getObat(search: query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          for (var obat in results) {
            _obatStokMap[obat.idObat] = obat.stok;
          }
        });
      }
    } catch (e) {
      // ignore
    } finally {
      if (mounted) setState(() => _isLoadingSearch = false);
    }
  }

  void _addToCart(ObatModel obat) {
    setState(() {
      final existingIndex = _cart.indexWhere((item) => item.idObat == obat.idObat);
      if (existingIndex >= 0) {
        final existingItem = _cart[existingIndex];
        if (existingItem.jumlah < obat.stok) {
          _cart[existingIndex] = DetailTransaksiModel(
            idDetail: 0,
            idTransaksi: 0,
            idObat: obat.idObat,
            namaObat: obat.namaObat,
            kodeObat: obat.kodeObat,
            jumlah: existingItem.jumlah + 1,
            hargaSatuan: obat.hargaJual,
            subtotal: (existingItem.jumlah + 1) * obat.hargaJual,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Stok tidak mencukupi')));
        }
      } else {
        if (obat.stok > 0) {
          _cart.add(DetailTransaksiModel(
            idDetail: 0,
            idTransaksi: 0,
            idObat: obat.idObat,
            namaObat: obat.namaObat,
            kodeObat: obat.kodeObat,
            jumlah: 1,
            hargaSatuan: obat.hargaJual,
            subtotal: obat.hargaJual,
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Stok habis')));
        }
      }
    });
  }

  void _decrementCartItem(int index) {
    final item = _cart[index];
    setState(() {
      if (item.jumlah > 1) {
        _cart[index] = DetailTransaksiModel(
          idDetail: item.idDetail,
          idTransaksi: item.idTransaksi,
          idObat: item.idObat,
          namaObat: item.namaObat,
          kodeObat: item.kodeObat,
          jumlah: item.jumlah - 1,
          hargaSatuan: item.hargaSatuan,
          subtotal: (item.jumlah - 1) * item.hargaSatuan,
        );
      } else {
        _cart.removeAt(index);
      }
    });
  }

  void _incrementCartItem(int index) {
    final item = _cart[index];
    final maxStock = _obatStokMap[item.idObat] ?? 999;
    if (item.jumlah < maxStock) {
      setState(() {
        _cart[index] = DetailTransaksiModel(
          idDetail: item.idDetail,
          idTransaksi: item.idTransaksi,
          idObat: item.idObat,
          namaObat: item.namaObat,
          kodeObat: item.kodeObat,
          jumlah: item.jumlah + 1,
          hargaSatuan: item.hargaSatuan,
          subtotal: (item.jumlah + 1) * item.hargaSatuan,
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Stok tidak mencukupi')));
    }
  }

  void _removeFromCart(int index) {
    setState(() => _cart.removeAt(index));
  }

  double get _totalHarga {
    return _cart.fold(0, (sum, item) => sum + item.subtotal);
  }

  void _prosesTransaksi() {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Keranjang kosong')));
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final bayarText = _bayarController.text.replaceAll(RegExp(r'[^0-9]'), '');
            final bayar = double.tryParse(bayarText) ?? 0;
            final kembalian = bayar - _totalHarga;

            return AlertDialog(
              title: const Text('Pembayaran'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Total: ${currencyFormatter.format(_totalHarga)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _bayarController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Jumlah Bayar (Rp)'),
                    onChanged: (val) => setDialogState(() {}),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Kembalian: ${kembalian < 0 ? 0 : currencyFormatter.format(kembalian)}',
                    style: TextStyle(
                      fontSize: 16,
                      color: kembalian < 0 ? AppTheme.errorRed : AppTheme.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _bayarController.clear();
                    Navigator.pop(context);
                  },
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: kembalian >= 0 && !_isProcessing
                      ? () async {
                          setDialogState(() => _isProcessing = true);
                          try {
                            final transaksi = TransaksiModel(
                              idTransaksi: 0,
                              noFaktur: '',
                              tanggalTransaksi: '',
                              idUser: 1, // Default ID User for now (admin)
                              idPelanggan: 1, // Default Pelanggan Umum
                              totalHarga: _totalHarga,
                              jumlahBayar: bayar,
                              kembalian: kembalian,
                              items: _cart,
                            );
                            
                            final result = await _transaksiService.tambahTransaksi(transaksi);
                            
                            if (context.mounted) {
                              Navigator.pop(context); // Close dialog
                              final cartCopy = List<DetailTransaksiModel>.from(_cart);
                              final finalTotal = _totalHarga;
                              setState(() {
                                _cart.clear();
                                _bayarController.clear();
                              });
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StrukScreen(
                                    noFaktur: result['no_faktur'] ?? 'TRX-UNKNOWN',
                                    items: cartCopy,
                                    totalHarga: finalTotal,
                                    jumlahBayar: bayar,
                                    kembalian: kembalian,
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                            }
                          } finally {
                            setDialogState(() => _isProcessing = false);
                          }
                        }
                      : null,
                  child: _isProcessing ? const CircularProgressIndicator(color: Colors.white) : const Text('Bayar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Point of Sale (POS)')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Input Pencarian
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Cari Obat di Katalog',
                hintText: 'Masukkan nama atau kode obat...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.primaryBlue),
                suffixIcon: _isLoadingSearch
                    ? const Padding(padding: EdgeInsets.all(12.0), child: CircularProgressIndicator(strokeWidth: 2))
                    : null,
              ),
              onChanged: _searchObat,
            ),
          ),
          
          // Katalog Obat (Daftar Pencarian)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Icon(Icons.apps, color: AppTheme.primaryBlue, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Katalog Obat',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (_searchResults.isNotEmpty)
            Expanded(
              flex: 3,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final obat = _searchResults[index];
                  final outOfStock = obat.stok <= 0;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    elevation: 1,
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: outOfStock ? AppTheme.errorRed.withAlpha(25) : AppTheme.primaryBlue.withAlpha(25),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.medication,
                          color: outOfStock ? AppTheme.errorRed : AppTheme.primaryBlue,
                        ),
                      ),
                      title: Text(obat.namaObat, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        'Kode: ${obat.kodeObat} • Stok: ${obat.stok} ${obat.satuan}',
                        style: TextStyle(color: outOfStock ? AppTheme.errorRed : Colors.grey.shade600),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            currencyFormatter.format(obat.hargaJual),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              minimumSize: const Size(60, 32),
                            ),
                            onPressed: outOfStock ? null : () => _addToCart(obat),
                            child: const Text('Pilih', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          else
            const Expanded(
              flex: 1,
              child: Center(
                child: Text('Katalog kosong. Cari obat di atas...', style: TextStyle(color: Colors.grey)),
              ),
            ),

          const Divider(height: 24, thickness: 1.5),

          // Keranjang Belanja
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shopping_cart, color: AppTheme.primaryGreen, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Keranjang Belanja',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Text(
                  '${_cart.length} Item',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            flex: 3,
            child: _cart.isEmpty
                ? const Center(child: Text('Keranjang masih kosong', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _cart.length,
                    itemBuilder: (context, index) {
                      final item = _cart[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 1.5,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryGreen.withAlpha(25),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.shopping_basket, color: AppTheme.primaryGreen, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.namaObat ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Harga: ${currencyFormatter.format(item.hargaSatuan)}',
                                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, color: AppTheme.primaryBlue, size: 22),
                                    onPressed: () => _decrementCartItem(index),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                    child: Text(
                                      '${item.jumlah}',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryBlue, size: 22),
                                    onPressed: () => _incrementCartItem(index),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    currencyFormatter.format(item.subtotal),
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: AppTheme.errorRed, size: 22),
                                    onPressed: () => _removeFromCart(index),
                                    padding: const EdgeInsets.only(left: 10),
                                    constraints: const BoxConstraints(),
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 10, offset: const Offset(0, -5))
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Pembayaran', style: TextStyle(fontSize: 16)),
                    Text(
                      currencyFormatter.format(_totalHarga),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Proses Transaksi',
                  onPressed: _prosesTransaksi,
                  backgroundColor: AppTheme.primaryGreen,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
