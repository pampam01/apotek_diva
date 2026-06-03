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
                              setState(() {
                                _cart.clear();
                                _bayarController.clear();
                              });
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => StrukScreen(transaksiResult: result)),
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
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Cari Obat',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isLoadingSearch
                    ? const Padding(padding: EdgeInsets.all(12.0), child: CircularProgressIndicator(strokeWidth: 2))
                    : null,
              ),
              onChanged: _searchObat,
            ),
          ),
          if (_searchResults.isNotEmpty)
            Expanded(
              flex: 1,
              child: Container(
                color: AppTheme.lightGray,
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final obat = _searchResults[index];
                    return ListTile(
                      title: Text(obat.namaObat),
                      subtitle: Text('${obat.kodeObat} - Stok: ${obat.stok}'),
                      trailing: Text(currencyFormatter.format(obat.hargaJual)),
                      onTap: () => _addToCart(obat),
                    );
                  },
                ),
              ),
            ),
          Expanded(
            flex: 2,
            child: _cart.isEmpty
                ? const Center(child: Text('Keranjang Kosong'))
                : ListView.builder(
                    itemCount: _cart.length,
                    itemBuilder: (context, index) {
                      final item = _cart[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          title: Text(item.namaObat ?? ''),
                          subtitle: Text('Harga: ${currencyFormatter.format(item.hargaSatuan)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: AppTheme.primaryBlue, size: 20),
                                onPressed: () => _decrementCartItem(index),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text('${item.jumlah}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryBlue, size: 20),
                                onPressed: () => _incrementCartItem(index),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                currencyFormatter.format(item.subtotal),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: AppTheme.errorRed, size: 20),
                                onPressed: () => _removeFromCart(index),
                                padding: const EdgeInsets.only(left: 8),
                                constraints: const BoxConstraints(),
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
