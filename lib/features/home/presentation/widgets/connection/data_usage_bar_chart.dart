import 'package:flutter/material.dart';

class DataUsageBarChart extends StatelessWidget {
  const DataUsageBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    // UI mockeada, puedes reemplazar con una gráfica real (ej: fl_chart)
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('Download', style: TextStyle(color: Colors.green)),
            Text('Upload', style: TextStyle(color: Colors.purple)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _bar('Mar', 0.6, 0.1, '82.0 GB', '5.6 GB'),
            _bar('Apr', 1.0, 0.07, '125.4 GB', '3.9 GB'),
            _bar('May', 0.08, 0.03, '10.6 GB', '1.6 GB'),
          ],
        ),
      ],
    );
  }

  static Widget _bar(
    String month,
    double download,
    double upload,
    String dText,
    String uText,
  ) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 18,
              height: 80 * download,
              color: Colors.green,
              alignment: Alignment.bottomCenter,
              child: Text(
                dText,
                style: const TextStyle(fontSize: 10, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 10,
              height: 80 * upload,
              color: Colors.purple,
              alignment: Alignment.bottomCenter,
              child: Text(
                uText,
                style: const TextStyle(fontSize: 8, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(month, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
