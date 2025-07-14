import 'package:equatable/equatable.dart';

/// Entidad que representa los datos de tráfico para un mes específico
class TrafficData extends Equatable {
  final String month;
  final String year;
  final double downloadGB;
  final double uploadGB;
  final double totalGB;

  const TrafficData({
    required this.month,
    required this.year,
    required this.downloadGB,
    required this.uploadGB,
    required this.totalGB,
  });

  @override
  List<Object?> get props => [month, year, downloadGB, uploadGB, totalGB];
}
