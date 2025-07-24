import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/ticket_category.dart';
import '../repositories/ticket_category_repository.dart';

/// Caso de uso para obtener las categorías de tickets de soporte
class GetTicketCategories implements UseCase<List<TicketCategory>, NoParams> {
  final TicketCategoryRepository repository;

  GetTicketCategories(this.repository);

  @override
  Future<Either<Failure, List<TicketCategory>>> call(NoParams params) async {
    return await repository.getTicketCategories();
  }
}
