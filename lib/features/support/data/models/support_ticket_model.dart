import '../../domain/entities/support_ticket.dart';

class SupportTicketModel extends SupportTicket {
  const SupportTicketModel({
    required super.customerName,
    required super.category,
    required super.type,
    required super.description,
    required super.customerId,
    super.id,
    super.files,
    super.createdAt,
  });

  /// Crea un modelo a partir de un mapa JSON
  factory SupportTicketModel.fromJson(Map<String, dynamic> json) {
    return SupportTicketModel(
      id: json['id'],
      customerName: json['customer_name'],
      category: json['category'],
      type: json['type'],
      description: json['description'],
      customerId: json['customer_id_fk'],
      files: json['file'] != null ? List<String>.from(json['file']) : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  /// Convierte el modelo a un mapa JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'customer_name': customerName,
      'category': category,
      'type': type,
      'description': description,
      'customer_id_fk': customerId,
      if (files != null) 'file': files,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}
