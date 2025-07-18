import 'package:equatable/equatable.dart';

class Service extends Equatable {
  final int serviceId;
  final DateTime createdAt;
  final num value;
  final String name;
  final String? description;
  final int transactionTypeFk;
  final int transactionTypeId;
  final String type;
  final String category;

  const Service({
    required this.serviceId,
    required this.createdAt,
    required this.value,
    required this.name,
    required this.transactionTypeFk,
    required this.transactionTypeId,
    required this.type,
    required this.category,
    this.description,
  });

  @override
  List<Object?> get props => [
    serviceId,
    createdAt,
    value,
    name,
    description,
    transactionTypeFk,
    transactionTypeId,
    type,
    category,
  ];
}
