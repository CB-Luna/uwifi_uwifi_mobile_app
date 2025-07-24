import '../../domain/entities/ticket_category.dart';

/// Modelo de datos para la categoría de ticket de soporte
class TicketCategoryModel extends TicketCategory {
  const TicketCategoryModel({
    required super.id,
    required super.issueName,
    required super.category,
    required super.createdAt,
  });

  /// Crea un modelo a partir de un mapa JSON
  factory TicketCategoryModel.fromJson(Map<String, dynamic> json) {
    return TicketCategoryModel(
      id: json['id'],
      issueName: json['issue_name'],
      category: json['category_name'],
      createdAt: json['created_at'] is String
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  /// Convierte el modelo a un mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'issue_name': issueName,
      'category_name': category,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
