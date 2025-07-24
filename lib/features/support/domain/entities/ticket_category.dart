import 'package:equatable/equatable.dart';

/// Entidad que representa una categoría de ticket de soporte
class TicketCategory extends Equatable {
  final int id;
  final String issueName;
  final String category;
  final DateTime createdAt;

  const TicketCategory({
    required this.id,
    required this.issueName,
    required this.category,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, issueName, category, createdAt];
}
