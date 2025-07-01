import 'package:equatable/equatable.dart';

/// Clase base para todos los fallos
abstract class Failure extends Equatable {
  const Failure();

  @override
  List<Object?> get props => [];
}

/// Fallo cuando ocurre un error en el servidor
class ServerFailure extends Failure {
  const ServerFailure();
}

/// Fallo cuando ocurre un error en la caché local
class CacheFailure extends Failure {
  const CacheFailure();
}

/// Fallo cuando no hay conexión a internet
class NetworkFailure extends Failure {
  const NetworkFailure();
}

/// Fallo cuando no se encuentra un recurso solicitado
class NotFoundFailure extends Failure {
  const NotFoundFailure();
}

/// Fallo cuando un usuario no está autenticado
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure();
}

/// Fallo durante el proceso de autenticación
class AuthenticationFailure extends Failure {
  final String message;

  const AuthenticationFailure(this.message);

  @override
  List<Object?> get props => [message];
}
