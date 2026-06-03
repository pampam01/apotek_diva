import 'package:flutter/material.dart';
import '../models/obat_model.dart';
import '../services/obat_service.dart';
import '../widgets/obat_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_message.dart';
import '../widgets/custom_text_field.dart';
import 'form_obat_screen.dart';

class StokObatScreen extends StatefulWidget {
  const StokObatScreen({super.key});

  @override
  State<StokObatScreen> createState() => _StokObatScreenState();
}

class _StokObatScreenState extends State<StokObatScreen> {
  final _obatService = ObatService();
  final _searchController = TextEditingController();
  
  List<ObatModel> _obatList = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData([String search = '']) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _obatService.getObat(search: search);
      if (mounted) {
        setState(() {
          _obatList = data;
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

  void _confirmDelete(ObatModel obat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Obat'),
        content: Text('Yakin ingin menghapus ${obat.namaObat}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _obatService.hapusObat(obat.idObat);
                _loadData(_searchController.text);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                  );
                }
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stok Obat'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomTextField(
              controller: _searchController,
              label: 'Cari Obat',
              hint: 'Nama atau Kode',
              prefixIcon: Icons.search,
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _loadData();
                },
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const LoadingWidget()
                : _error != null
                    ? ErrorMessage(message: _error!, onRetry: () => _loadData(_searchController.text))
                    : _obatList.isEmpty
                        ? const Center(child: Text('Tidak ada obat ditemukan'))
                        : RefreshIndicator(
                            onRefresh: () => _loadData(_searchController.text),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _obatList.length,
                              itemBuilder: (context, index) {
                                final obat = _obatList[index];
                                return ObatCard(
                                  obat: obat,
                                  onEdit: () async {
                                    final res = await Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => FormObatScreen(obat: obat)),
                                    );
                                    if (res == true) _loadData(_searchController.text);
                                  },
                                  onDelete: () => _confirmDelete(obat),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormObatScreen()),
          );
          if (res == true) _loadData(_searchController.text);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
