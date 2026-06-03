import 'package:flutter/material.dart';
import '../models/obat_model.dart';
import '../services/obat_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class FormObatScreen extends StatefulWidget {
  final ObatModel? obat; // Jika null berarti tambah, jika ada berarti edit

  const FormObatScreen({super.key, this.obat});

  @override
  State<FormObatScreen> createState() => _FormObatScreenState();
}

class _FormObatScreenState extends State<FormObatScreen> {
  final _formKey = GlobalKey<FormState>();
  final _obatService = ObatService();
  
  final _kodeController = TextEditingController();
  final _namaController = TextEditingController();
  final _hargaBeliController = TextEditingController();
  final _hargaJualController = TextEditingController();
  final _stokController = TextEditingController();
  final _kadaluarsaController = TextEditingController();
  final _keteranganController = TextEditingController();

  int _selectedKategori = 1;
  String _selectedSatuan = 'Tablet';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _kategoriList = [
    {'id': 1, 'nama': 'Analgesik'},
    {'id': 2, 'nama': 'Antibiotik'},
    {'id': 3, 'nama': 'Vitamin'},
    {'id': 4, 'nama': 'Obat Batuk'},
  ];

  final List<String> _satuanList = ['Tablet', 'Kapsul', 'Syrup', 'Botol', 'Pcs', 'Salep'];

  @override
  void initState() {
    super.initState();
    if (widget.obat != null) {
      final o = widget.obat!;
      _kodeController.text = o.kodeObat;
      _namaController.text = o.namaObat;
      _selectedKategori = o.idKategori;
      _hargaBeliController.text = o.hargaBeli.toInt().toString();
      _hargaJualController.text = o.hargaJual.toInt().toString();
      _stokController.text = o.stok.toString();
      _selectedSatuan = o.satuan;
      _kadaluarsaController.text = o.tanggalKadaluarsa;
      _keteranganController.text = o.keterangan ?? '';
    } else {
      // Auto-generate unique code OBT-XXXXX
      _kodeController.text = 'OBT-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
      _selectedKategori = 1;
      _selectedSatuan = 'Tablet';
      _kadaluarsaController.text = '2026-12-31';
    }
  }

  void _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final obat = ObatModel(
        idObat: widget.obat?.idObat ?? 0,
        kodeObat: _kodeController.text,
        namaObat: _namaController.text,
        idKategori: _selectedKategori,
        hargaBeli: double.parse(_hargaBeliController.text),
        hargaJual: double.parse(_hargaJualController.text),
        stok: int.parse(_stokController.text),
        satuan: _selectedSatuan,
        tanggalKadaluarsa: _kadaluarsaController.text,
        keterangan: _keteranganController.text,
      );

      if (widget.obat == null) {
        await _obatService.tambahObat(obat);
      } else {
        await _obatService.updateObat(obat);
      }

      if (mounted) {
        Navigator.pop(context, true); // Return true indicating success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.obat == null ? 'Tambah Obat' : 'Edit Obat'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(
              controller: _kodeController,
              label: 'Kode Obat (Otomatis)',
              readOnly: true,
              validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
            ),
            CustomTextField(
              controller: _namaController,
              label: 'Nama Obat',
              validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: DropdownButtonFormField<int>(
                value: _selectedKategori,
                decoration: const InputDecoration(labelText: 'Kategori Obat'),
                items: _kategoriList.map((k) {
                  return DropdownMenuItem<int>(
                    value: k['id'] as int,
                    child: Text(k['nama'] as String),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedKategori = val);
                  }
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _hargaBeliController,
                    label: 'Harga Beli',
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    controller: _hargaJualController,
                    label: 'Harga Jual',
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _stokController,
                    label: 'Stok',
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: DropdownButtonFormField<String>(
                      value: _selectedSatuan,
                      decoration: const InputDecoration(labelText: 'Satuan'),
                      items: _satuanList.map((s) {
                        return DropdownMenuItem<String>(
                          value: s,
                          child: Text(s),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedSatuan = val);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            CustomTextField(
              controller: _kadaluarsaController,
              label: 'Tanggal Kadaluarsa (YYYY-MM-DD)',
              validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
            ),
            CustomTextField(
              controller: _keteranganController,
              label: 'Keterangan (Opsional)',
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Simpan',
              onPressed: _simpan,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
