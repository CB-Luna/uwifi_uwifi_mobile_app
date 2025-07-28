import 'package:equatable/equatable.dart';

/// Entidad que representa una visualización de video por un usuario
class MediaVisualization extends Equatable {
  final String mediaFileId;
  final int customerId;
  final int pointsEarned;
  final int customerAfiliateId;

  const MediaVisualization({
    required this.mediaFileId,
    required this.customerId,
    required this.pointsEarned,
    required this.customerAfiliateId,
  });

  @override
  List<Object?> get props => [
        mediaFileId,
        customerId,
        pointsEarned,
        customerAfiliateId,
      ];
}
