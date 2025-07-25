import 'package:equatable/equatable.dart';

/// Entidad que representa un ticket de soporte
class SupportTicket extends Equatable {
  final int? id;
  final String customerName;
  final String category;
  final String type;
  final String description;
  final int customerId;
  final List<String>? files;
  final DateTime? createdAt;

  const SupportTicket({
    required this.customerName,
    required this.category,
    required this.type,
    required this.description,
    required this.customerId,
    this.id,
    this.files,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    customerName,
    category,
    type,
    description,
    customerId,
    files,
    createdAt,
  ];
}
