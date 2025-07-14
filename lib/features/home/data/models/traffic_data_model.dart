import 'package:uwifiapp/core/utils/app_logger.dart';

import '../../domain/entities/traffic_data.dart';

class TrafficDataModel extends TrafficData {
  const TrafficDataModel({
    required super.month,
    required super.year,
    required super.downloadGB,
    required super.uploadGB,
    required super.totalGB,
  });

  factory TrafficDataModel.fromJson(Map<String, dynamic> json) {
    AppLogger.navInfo('[DEBUG] 📝 TrafficDataModel: Procesando JSON: $json');

    // Convertir bytes a GB - los campos en la respuesta son total_rx y total_tx
    final double downloadBytes = json['total_rx']?.toDouble() ?? 0;
    final double uploadBytes = json['total_tx']?.toDouble() ?? 0;
    final double totalBytes = downloadBytes + uploadBytes;

    AppLogger.navInfo(
      '[DEBUG] 📝 TrafficDataModel: Bytes - download: $downloadBytes, upload: $uploadBytes',
    );

    // Extraer mes y año de la fecha
    final String dateStr = json['month'] ?? '';
    AppLogger.navInfo('[DEBUG] 📝 TrafficDataModel: Fecha original: $dateStr');

    String month = 'Ene';
    String year = '2023';

    if (dateStr.isNotEmpty) {
      final parts = dateStr.split('-');
      AppLogger.navInfo('[DEBUG] 📝 TrafficDataModel: Partes de fecha: $parts');

      if (parts.length >= 2) {
        year = parts[0];
        // Convertir número de mes a nombre abreviado
        final int monthNum = int.tryParse(parts[1]) ?? 1;
        month = _getMonthName(monthNum);
        AppLogger.navInfo(
          '[DEBUG] 📝 TrafficDataModel: Mes convertido: $monthNum -> $month',
        );
      }
    }

    // Factor de conversión de bytes a GB: 1 GB = 1024^3 bytes
    final double bytesToGB = 1024 * 1024 * 1024;

    // Convertir bytes a GB y redondear a 2 decimales para mejor visualización
    final downloadGB = downloadBytes / bytesToGB;
    final uploadGB = uploadBytes / bytesToGB;
    final totalGB = totalBytes / bytesToGB;

    AppLogger.navInfo(
      '[DEBUG] 📝 TrafficDataModel: GB convertidos - download: ${downloadGB.toStringAsFixed(2)}, upload: ${uploadGB.toStringAsFixed(2)}',
    );

    return TrafficDataModel(
      month: month,
      year: year,
      downloadGB: downloadGB,
      uploadGB: uploadGB,
      totalGB: totalGB,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': '$year-${_getMonthNumber(month)}',
      'total_rx': downloadGB * 1024 * 1024 * 1024, // Convertir GB a bytes
      'total_tx': uploadGB * 1024 * 1024 * 1024,
      'grand_total': (downloadGB + uploadGB) * 1024 * 1024 * 1024,
    };
  }

  // Método auxiliar para convertir número de mes a nombre
  static String _getMonthName(int month) {
    const monthNames = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return monthNames[month - 1];
  }

  // Método auxiliar para convertir nombre de mes a número
  static String _getMonthNumber(String month) {
    const monthNames = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    final index = monthNames.indexOf(month);
    return (index + 1).toString().padLeft(2, '0');
  }
}
