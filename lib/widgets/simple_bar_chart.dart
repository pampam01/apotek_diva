import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SimpleBarChart extends StatelessWidget {
  final List<double> data;
  final List<String> labels;
  final double maxY;

  const SimpleBarChart({
    super.key,
    required this.data,
    required this.labels,
    this.maxY = 100,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('Tidak ada data'));
    }

    final double actualMaxY = maxY > 0 ? maxY : 100;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(data.length, (index) {
        final heightPercentage = data[index] / actualMaxY;
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 30,
              height: (150.0 * (heightPercentage.isNaN || heightPercentage.isInfinite ? 0.0 : heightPercentage).clamp(0.0, 1.0)).toDouble(),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              labels[index],
              style: const TextStyle(fontSize: 10),
            ),
          ],
        );
      }),
    );
  }
}
