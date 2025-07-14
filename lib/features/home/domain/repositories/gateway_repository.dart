import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/data_usage.dart';

abstract class GatewayRepository {
  Future<Either<Failure, DataUsage>> getDataUsage(String customerId);
}
