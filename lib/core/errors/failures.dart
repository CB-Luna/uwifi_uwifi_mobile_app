import 'package:equatable/equatable.dart';

/// Clase base para todos los fallos
abstract class Failure extends Equatable {
  final String message;

  const Failure([this.message = '']);

  @override
  List<Object?> get props => [message];
}

/// Fallo cuando ocurre un error en el servidor
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Error en el servidor']);
}

/// Fallo cuando ocurre un error en la caché local
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Error en la caché']);
}

/// Fallo cuando no hay conexión a internet
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No hay conexión a internet']);
}

/// Fallo cuando no se encuentra un recurso solicitado
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Recurso no encontrado']);
}

/// Fallo cuando un usuario no está autenticado
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Usuario no autorizado']);
}

/// Fallo durante el proceso de autenticación
class AuthenticationFailure extends Failure {
  const AuthenticationFailure([super.message = 'Error de autenticación']);
}

/// Alias para AuthenticationFailure para mantener compatibilidad
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Error de autenticación']);
}
