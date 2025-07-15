import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/gateway_info.dart';
import '../repositories/gateway_info_repository.dart';

class GetGatewayInfo implements UseCase<GatewayInfo, String> {
  final GatewayInfoRepository repository;

  GetGatewayInfo(this.repository);

  @override
  Future<Either<Failure, GatewayInfo>> call(String params) async {
    return await repository.getGatewayInfo(params);
  }
}
