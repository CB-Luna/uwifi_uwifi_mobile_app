import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/support_ticket.dart';
import '../../domain/repositories/support_repository.dart';
import '../datasources/support_remote_data_source.dart';
import '../models/support_ticket_model.dart';

class SupportRepositoryImpl implements SupportRepository {
  final SupportRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  SupportRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, void>> createSupportTicket(SupportTicket ticket) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.createSupportTicket(
          SupportTicketModel(
            customerName: ticket.customerName,
            category: ticket.category,
            type: ticket.type,
            description: ticket.description,
            customerId: ticket.customerId,
            id: ticket.id,
            files: ticket.files,
            createdAt: ticket.createdAt,
            status: ticket.status,
            title: ticket.title,
            assignedTo: ticket.assignedTo,
          ),
        );
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<String>>> uploadTicketFiles(
    List<dynamic> files,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final fileUrls = await remoteDataSource.uploadTicketFiles(files);
        return Right(fileUrls);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getTicketCategories() async {
    if (await networkInfo.isConnected) {
      try {
        final categories = await remoteDataSource.getTicketCategories();
        return Right(categories);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<SupportTicket>>> getCustomerTickets({
    required int customerId,
    String? status,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final tickets = await remoteDataSource.getCustomerTickets(
          customerId: customerId,
          status: status,
        );
        return Right(tickets);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
