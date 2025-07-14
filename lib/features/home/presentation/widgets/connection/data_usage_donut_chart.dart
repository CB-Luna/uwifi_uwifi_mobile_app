import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/data_usage_bloc.dart';
import '../../bloc/data_usage_event.dart';
import '../../bloc/data_usage_state.dart';

/// Painter personalizado para dibujar el gráfico de donut con dos secciones
class DonutChartPainter extends CustomPainter {
  final double downloadPercentage;
  final double uploadPercentage;
  final Color downloadColor;
  final Color uploadColor;

  DonutChartPainter({
    required this.downloadPercentage,
    required this.uploadPercentage,
    required this.downloadColor,
    required this.uploadColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    const startAngle = -pi / 2; // Comenzar desde arriba (90 grados)
    
    // Grosor del anillo
    const strokeWidth = 25.0;
    
    // Crear un rectángulo para contener el círculo
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);
    
    // Dibujar el arco de descarga (verde)
    final downloadPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = downloadColor;
    
    // Dibujar el arco de subida (morado)
    final uploadPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = uploadColor;
    
    // Calcular ángulos
    final downloadSweepAngle = 2 * pi * downloadPercentage;
    final uploadSweepAngle = 2 * pi * uploadPercentage;
    
    // Dibujar arcos
    canvas.drawArc(rect, startAngle, downloadSweepAngle, false, downloadPaint);
    canvas.drawArc(
      rect, 
      startAngle + downloadSweepAngle, 
      uploadSweepAngle, 
      false, 
      uploadPaint
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class DataUsageDonutChart extends StatelessWidget {
  const DataUsageDonutChart({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataUsageBloc, DataUsageState>(
      builder: (context, state) {
        if (state is DataUsageLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is DataUsageLoaded) {
          // Convertir bytes a GB para mostrar
          final downloadGB = state.dataUsage.monthlyRx / (1024 * 1024 * 1024);
          final uploadGB = state.dataUsage.monthlyTx / (1024 * 1024 * 1024);
          final totalGB = state.dataUsage.monthlyTotal / (1024 * 1024 * 1024);
          
          // Calcular porcentajes
          final downloadPercentage = state.dataUsage.monthlyRx / state.dataUsage.monthlyTotal;
          final uploadPercentage = state.dataUsage.monthlyTx / state.dataUsage.monthlyTotal;
          
          // Colores para el gráfico
          const downloadColor = Color(0xFF4CAF50); // Verde
          const uploadColor = Color(0xFF9C27B0);   // Morado
          
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Total Used: ${totalGB.toStringAsFixed(2)} GB',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Download info
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: downloadColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Download: ${downloadGB.toStringAsFixed(2)} GB',
                          style: const TextStyle(
                            color: downloadColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    // Upload info
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: uploadColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Upload: ${uploadGB.toStringAsFixed(2)} GB',
                          style: const TextStyle(
                            color: uploadColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 180,
                  width: 180,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Donut chart
                      CustomPaint(
                        size: const Size(180, 180),
                        painter: DonutChartPainter(
                          downloadPercentage: downloadPercentage,
                          uploadPercentage: uploadPercentage,
                          downloadColor: downloadColor,
                          uploadColor: uploadColor,
                        ),
                      ),
                      // Porcentaje de descarga
                      Positioned(
                        top: 50,
                        child: Column(
                          children: [
                            Text(
                              '${(downloadPercentage * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                color: downloadColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const Text(
                              'Download',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      // Porcentaje de subida
                      Positioned(
                        bottom: 50,
                        child: Column(
                          children: [
                            Text(
                              '${(uploadPercentage * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                color: uploadColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const Text(
                              'Upload',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else if (state is DataUsageError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('Error: ${state.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Intentar cargar los datos nuevamente
                    context.read<DataUsageBloc>().add(
                      const GetDataUsageEvent(customerId: 'customer_id'),
                    );
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        } else {
          // Estado inicial o desconocido
          return const Center(child: Text('No hay datos disponibles'));
        }
      },
    );
  }
}
