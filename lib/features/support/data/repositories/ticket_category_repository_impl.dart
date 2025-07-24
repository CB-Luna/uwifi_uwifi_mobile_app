import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/ticket_category.dart';
import '../../domain/repositories/ticket_category_repository.dart';
import '../datasources/ticket_category_remote_data_source.dart';

class TicketCategoryRepositoryImpl implements TicketCategoryRepository {
  final TicketCategoryRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  TicketCategoryRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<TicketCategory>>> getTicketCategories() async {
    if (await networkInfo.isConnected) {
      try {
        final categories = await remoteDataSource.getTicketCategories();
        return Right(categories);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}
