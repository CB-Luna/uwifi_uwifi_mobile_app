import '../models/gateway_info_model.dart';

abstract class GatewayInfoRemoteDataSource {
  /// Calls the uwifi_gateway_zequence_info endpoint
  ///
  /// Throws a [ServerException] for all error codes
  Future<GatewayInfoModel> getGatewayInfo(String serialNumber);
}
