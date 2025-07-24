import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/ticket_category.dart';

/// Interfaz para el repositorio de categorías de tickets de soporte
abstract class TicketCategoryRepository {
  /// Obtiene todas las categorías de tickets de soporte
  Future<Either<Failure, List<TicketCategory>>> getTicketCategories();
}
