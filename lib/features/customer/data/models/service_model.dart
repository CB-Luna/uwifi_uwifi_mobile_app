import '../../domain/entities/service.dart';

class ServiceModel extends Service {
  const ServiceModel({
    required super.serviceId,
    required super.createdAt,
    required super.value,
    required super.name,
    required super.transactionTypeFk,
    required super.transactionTypeId,
    required super.type,
    required super.category,
    super.description,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      serviceId: json['service_id'],
      createdAt: DateTime.parse(json['created_at']),
      value: json['value'],
      name: json['name'],
      description: json['description'],
      transactionTypeFk: json['transaction_type_fk'],
      transactionTypeId: json['transaction_type_id'],
      type: json['type'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service_id': serviceId,
      'created_at': createdAt.toIso8601String(),
      'value': value,
      'name': name,
      'description': description,
      'transaction_type_fk': transactionTypeFk,
      'transaction_type_id': transactionTypeId,
      'type': type,
      'category': category,
    };
  }
}
