import 'package:equatable/equatable.dart';

class CustomerBundle extends Equatable {
  final int inventoryProductId;
  final String productStatus;
  final String gatewaySerialNumber;

  const CustomerBundle({
    required this.inventoryProductId,
    required this.productStatus,
    required this.gatewaySerialNumber,
  });

  @override
  List<Object?> get props => [inventoryProductId, productStatus, gatewaySerialNumber];
}
