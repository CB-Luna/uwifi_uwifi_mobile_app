import 'package:flutter/material.dart';

class DataUsageDonutChart extends StatelessWidget {
  const DataUsageDonutChart({super.key});

  @override
  Widget build(BuildContext context) {
    // UI mockeada, puedes reemplazar con una gráfica real (ej: fl_chart)
    return const Column(
      children: [
        Text(
          'Total Used: 12.22 GB',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text('Download: 10.58 GB', style: TextStyle(color: Colors.green)),
        Text('Upload: 1.64 GB', style: TextStyle(color: Colors.purple)),
        SizedBox(height: 16),
        SizedBox(
          height: 120,
          width: 120,
          child: Stack(
            children: [
              // Donut verde
              CircularProgressIndicator(
                value: 0.866,
                strokeWidth: 16,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                backgroundColor: Colors.purple,
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '86.6%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text('Download', style: TextStyle(fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
