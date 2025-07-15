import '../../domain/entities/customer_bundle.dart';

class CustomerBundleModel extends CustomerBundle {
  const CustomerBundleModel({
    required super.inventoryProductId,
    required super.productStatus,
    required super.gatewaySerialNumber,
  });

  factory CustomerBundleModel.fromJson(Map<String, dynamic> json) {
    // Extraer el gateway serial number de forma segura
    String serialNumber = '';
    if (json['gateway'] != null && json['gateway']['serie_no'] != null) {
      serialNumber = json['gateway']['serie_no'];
    }

    return CustomerBundleModel(
      inventoryProductId: json['inventory_product_id'] ?? 0,
      productStatus: json['product_status'] ?? '',
      gatewaySerialNumber: serialNumber,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inventory_product_id': inventoryProductId,
      'product_status': productStatus,
      'gateway_serial_number': gatewaySerialNumber,
    };
  }
}
