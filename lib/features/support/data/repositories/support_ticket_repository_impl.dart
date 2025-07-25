import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/support_ticket.dart';
import '../../domain/repositories/support_ticket_repository.dart';
import '../datasources/support_ticket_remote_data_source.dart';

class SupportTicketRepositoryImpl implements SupportTicketRepository {
  final SupportTicketRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  SupportTicketRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, void>> createSupportTicket(
    SupportTicket ticket,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.createSupportTicket(ticket);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<String>>> uploadTicketFiles(
    List<File> files,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final fileUrls = await remoteDataSource.uploadTicketFiles(files);
        return Right(fileUrls);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}
