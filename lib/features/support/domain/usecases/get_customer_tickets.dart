import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/support_ticket.dart';
import '../repositories/support_repository.dart';

class GetCustomerTickets implements UseCase<List<SupportTicket>, CustomerTicketsParams> {
  final SupportRepository repository;

  GetCustomerTickets(this.repository);

  @override
  Future<Either<Failure, List<SupportTicket>>> call(CustomerTicketsParams params) {
    return repository.getCustomerTickets(
      customerId: params.customerId,
      status: params.status,
    );
  }
}

class CustomerTicketsParams extends Equatable {
  final int customerId;
  final String? status;

  const CustomerTicketsParams({
    required this.customerId,
    this.status,
  });

  @override
  List<Object?> get props => [customerId, status];
}
