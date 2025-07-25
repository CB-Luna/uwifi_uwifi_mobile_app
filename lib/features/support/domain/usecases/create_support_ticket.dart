import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/support_ticket.dart';
import '../repositories/support_ticket_repository.dart';

class CreateSupportTicket implements UseCase<void, SupportTicketParams> {
  final SupportTicketRepository repository;

  CreateSupportTicket(this.repository);

  @override
  Future<Either<Failure, void>> call(SupportTicketParams params) {
    return repository.createSupportTicket(params.ticket);
  }
}

class SupportTicketParams {
  final SupportTicket ticket;

  SupportTicketParams(this.ticket);
}
