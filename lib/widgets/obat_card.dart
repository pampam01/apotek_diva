import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/obat_model.dart';
import '../theme/app_theme.dart';

class ObatCard extends StatelessWidget {
  final ObatModel obat;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ObatCard({
    super.key,
    required this.obat,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final isLowStock = obat.stok < 10;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      obat.namaObat,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onEdit != null || onDelete != null)
                    Row(
                      children: [
                        if (onEdit != null)
                          IconButton(
                            icon: const Icon(Icons.edit, color: AppTheme.primaryBlue, size: 20),
                            onPressed: onEdit,
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        if (onDelete != null)
                          IconButton(
                            icon: const Icon(Icons.delete, color: AppTheme.errorRed, size: 20),
                            onPressed: onDelete,
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kode: ${obat.kodeObat}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    obat.namaKategori ?? 'Tanpa Kategori',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currencyFormatter.format(obat.hargaJual),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isLowStock ? AppTheme.errorRed.withAlpha(25) : AppTheme.primaryBlue.withAlpha(25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Stok: ${obat.stok} ${obat.satuan}',
                      style: TextStyle(
                        color: isLowStock ? AppTheme.errorRed : AppTheme.primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
