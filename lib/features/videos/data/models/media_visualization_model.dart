import '../../domain/entities/media_visualization.dart';

/// Modelo para la entidad MediaVisualization
class MediaVisualizationModel extends MediaVisualization {
  const MediaVisualizationModel({
    required super.mediaFileId,
    required super.customerId,
    required super.pointsEarned,
    required super.customerAfiliateId,
  });

  /// Crea una instancia desde un mapa de datos (JSON)
  factory MediaVisualizationModel.fromJson(Map<String, dynamic> json) {
    return MediaVisualizationModel(
      mediaFileId: json['media_file_fk'],
      customerId: json['customer_fk'],
      pointsEarned: json['points_earned'],
      customerAfiliateId: json['customer_afiliate_id'],
    );
  }

  /// Convierte la instancia a JSON
  Map<String, dynamic> toJson() {
    return {
      'media_file_fk': mediaFileId,
      'customer_fk': customerId,
      'points_earned': pointsEarned,
      'customer_afiliate_id': customerAfiliateId,
    };
  }

  /// Crea una instancia desde una entidad
  factory MediaVisualizationModel.fromEntity(MediaVisualization entity) {
    return MediaVisualizationModel(
      mediaFileId: entity.mediaFileId,
      customerId: entity.customerId,
      pointsEarned: entity.pointsEarned,
      customerAfiliateId: entity.customerAfiliateId,
    );
  }
}
