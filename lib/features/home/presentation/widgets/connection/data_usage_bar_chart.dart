import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uwifiapp/core/utils/app_logger.dart';

import '../../bloc/traffic_bloc.dart';
import '../../bloc/traffic_event.dart';
import '../../bloc/traffic_state.dart';

class DataUsageBarChart extends StatefulWidget {
  final String customerId;

  const DataUsageBarChart({required this.customerId, super.key});

  @override
  State<DataUsageBarChart> createState() => _DataUsageBarChartState();
}

class _DataUsageBarChartState extends State<DataUsageBarChart> {
  @override
  void initState() {
    super.initState();
    _loadTrafficData();
  }

  void _loadTrafficData() {
    // Calcular fechas para los últimos 3 meses
    final now = DateTime.now();
    final endDate = DateFormat('yyyy-MM-dd').format(now);

    // Fecha de inicio: 3 meses atrás
    final startDate = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime(now.year, now.month - 2, now.day));

    // Usar el TrafficBloc global
    final bloc = context.read<TrafficBloc>();
    bloc.add(
      GetTrafficInformationEvent(
        customerId: widget.customerId,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrafficBloc, TrafficState>(
      builder: (context, state) {
        if (state is TrafficLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TrafficLoaded) {
          final trafficData = state.trafficData;

          // Log para depuración
          AppLogger.navInfo(
            '[DEBUG] 🔍 DataUsageBarChart: Datos recibidos: ${trafficData.length} registros',
          );
          for (final data in trafficData) {
            AppLogger.navInfo(
              '[DEBUG] 🔍 DataUsageBarChart: Mes: ${data.month}, Download: ${data.downloadGB} GB, Upload: ${data.uploadGB} GB',
            );
          }

          // Si no hay datos, mostrar mensaje más informativo
          if (trafficData.isEmpty) {
            AppLogger.navInfo(
              '[DEBUG] ⚠️ DataUsageBarChart: No hay datos de tráfico disponibles',
            );
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, size: 48, color: Colors.blue),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay datos de tráfico disponibles',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'No se encontraron registros de uso de datos para los últimos 3 meses',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadTrafficData,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          // Encontrar el valor máximo para normalizar las barras
          double maxDownload = 0;
          double maxUpload = 0;

          for (final data in trafficData) {
            if (data.downloadGB > maxDownload) maxDownload = data.downloadGB;
            if (data.uploadGB > maxUpload) maxUpload = data.uploadGB;
          }

          // Usar el máximo entre download y upload para normalizar
          final maxValue = maxDownload > maxUpload ? maxDownload : maxUpload;

          // Calcular totales para mostrar en la leyenda
          double totalDownload = 0;
          double totalUpload = 0;
          for (final data in trafficData) {
            totalDownload += data.downloadGB;
            totalUpload += data.uploadGB;
          }

          AppLogger.navInfo(
            '[DEBUG] 📈 DataUsageBarChart: Totales - Download: ${totalDownload.toStringAsFixed(2)} GB, Upload: ${totalUpload.toStringAsFixed(2)} GB',
          );

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Download info
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Download',
                          style: TextStyle(
                            color: Colors.green,
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
                            color: Colors.purple,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Upload',
                          style: TextStyle(
                            color: Colors.purple,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Envolver en RepaintBoundary para optimizar el rendimiento
              RepaintBoundary(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: trafficData.map((data) {
                  // Normalizar valores para la visualización
                  final downloadRatio = maxValue > 0
                      ? data.downloadGB / maxValue
                      : 0.0;
                  final uploadRatio = maxValue > 0
                      ? data.uploadGB / maxValue
                      : 0.0;

                  // Log para depuración de ratios
                  AppLogger.navInfo(
                    '[DEBUG] 📊 Bar para ${data.month}: downloadRatio=$downloadRatio, uploadRatio=$uploadRatio, maxValue=$maxValue',
                  );

                  // Formatear texto para mostrar GB con 1 decimal
                  final downloadText =
                      '${data.downloadGB.toStringAsFixed(1)} GB';
                  final uploadText = '${data.uploadGB.toStringAsFixed(1)} GB';

                  return _bar(
                    data.month,
                    downloadRatio,
                    uploadRatio,
                    downloadText,
                    uploadText,
                  );
                }).toList(),
                ),
              ),
            ],
          );
        } else if (state is TrafficError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('Error: ${state.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadTrafficData,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        } else {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No hay datos disponibles',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _bar(
    String month,
    double download,
    double upload,
    String dText,
    String uText,
  ) {
    // Log para depuración de las alturas de las barras
    AppLogger.navInfo(
      '[DEBUG] 📏 Altura de barras para $month: download=${70 * download}, upload=${70 * upload}',
    );

    // Altura mínima para barras muy pequeñas pero no cero
    const double minHeight = 8.0;
    const double maxHeight = 100.0; // Altura máxima reducida para las barras
    final double downloadHeight = download > 0
        ? max(min(70 * download, maxHeight), minHeight)
        : 0;
    final double uploadHeight = upload > 0
        ? max(min(70 * upload, maxHeight), minHeight)
        : 0;

    return Column(
      children: [
        // Etiquetas encima de las barras (como en la imagen 2)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Etiqueta de descarga
            Container(
              width: 40,
              alignment: Alignment.center,
              child: Text(
                dText,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 8),
            // Etiqueta de subida
            Container(
              width: 40,
              alignment: Alignment.center,
              child: Text(
                uText,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.purple,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        // Barras
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Barra de descarga
            Container(
              width: 25,
              height: downloadHeight,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 8),
            // Barra de subida
            Container(
              width: 25,
              height: uploadHeight,
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Mes
        Text(
          month,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
