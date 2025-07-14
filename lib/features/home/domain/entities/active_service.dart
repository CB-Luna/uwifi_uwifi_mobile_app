class ActiveService {
  final int quantity;
  final String createdAt;
  final int serviceId;
  final String name;
  final String description;
  final int transactionTypeFk;
  final String type;
  final double value;

  const ActiveService({
    required this.quantity,
    required this.createdAt,
    required this.serviceId,
    required this.name,
    required this.description,
    required this.transactionTypeFk,
    required this.type,
    required this.value,
  });
}
