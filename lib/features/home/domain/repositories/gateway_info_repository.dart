import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/gateway_info.dart';

abstract class GatewayInfoRepository {
  /// Gets the gateway information using the serial number
  ///
  /// Returns [GatewayInfo] if successful, [Failure] otherwise
  Future<Either<Failure, GatewayInfo>> getGatewayInfo(String serialNumber);
}
