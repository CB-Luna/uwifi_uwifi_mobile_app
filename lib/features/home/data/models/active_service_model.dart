import 'package:uwifiapp/core/utils/app_logger.dart';
import '../../domain/entities/active_service.dart';

class ActiveServiceModel extends ActiveService {
  const ActiveServiceModel({
    required super.quantity,
    required super.createdAt,
    required super.serviceId,
    required super.name,
    required super.description,
    required super.transactionTypeFk,
    required super.type,
    required super.value,
  });

  factory ActiveServiceModel.fromJson(Map<String, dynamic> json) {
    AppLogger.navInfo('Procesando servicio activo: $json');
    
    return ActiveServiceModel(
      quantity: json['quantity'] ?? 0,
      createdAt: json['created_at'] ?? '',
      serviceId: json['service_id'] ?? 0,
      name: json['name'] ?? 'Sin nombre',
      description: json['description'] ?? 'Sin descripción',
      transactionTypeFk: json['transaction_type_fk'] ?? 0,
      type: json['type'] ?? 'Desconocido',
      value: (json['value'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quantity': quantity,
      'created_at': createdAt,
      'service_id': serviceId,
      'name': name,
      'description': description,
      'transaction_type_fk': transactionTypeFk,
      'type': type,
      'value': value,
    };
  }
}
