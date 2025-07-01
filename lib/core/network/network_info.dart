import 'package:internet_connection_checker/internet_connection_checker.dart';

/// Interfaz para verificar la conexión a internet
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

/// Implementación concreta de NetworkInfo
class NetworkInfoImpl implements NetworkInfo {
  final InternetConnectionChecker connectionChecker;

  NetworkInfoImpl({required this.connectionChecker});

  @override
  Future<bool> get isConnected => connectionChecker.hasConnection;
}
