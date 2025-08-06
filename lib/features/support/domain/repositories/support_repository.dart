import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/support_ticket.dart';

abstract class SupportRepository {
  /// Crea un ticket de soporte
  Future<Either<Failure, void>> createSupportTicket(SupportTicket ticket);
  
  /// Sube archivos para un ticket de soporte
  Future<Either<Failure, List<String>>> uploadTicketFiles(List<dynamic> files);
  
  /// Obtiene las categorías de tickets disponibles
  Future<Either<Failure, List<dynamic>>> getTicketCategories();
  
  /// Obtiene los tickets de un cliente específico
  Future<Either<Failure, List<SupportTicket>>> getCustomerTickets({
    required int customerId,
    String? status,
  });
}
