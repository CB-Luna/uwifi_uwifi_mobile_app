/// Excepción cuando ocurre un error en el servidor
class ServerException implements Exception {
  final String message;

  ServerException([this.message = 'Error en el servidor']);
}

/// Excepción cuando ocurre un error en la caché local
class CacheException implements Exception {
  final String message;

  CacheException([this.message = 'Error en la caché']);
}

/// Excepción cuando no se puede establecer conexión a internet
class NetworkException implements Exception {
  final String message;

  NetworkException([this.message = 'No hay conexión a internet']);
}

/// Excepción cuando no se encuentra un recurso solicitado
class NotFoundException implements Exception {
  final String message;

  NotFoundException([this.message = 'Recurso no encontrado']);
}

/// Excepción cuando un usuario no está autenticado
class UnauthorizedException implements Exception {
  final String message;

  UnauthorizedException([this.message = 'Usuario no autorizado']);
}

/// Excepción durante el proceso de autenticación
class AuthException implements Exception {
  final String message;

  AuthException([this.message = 'Error de autenticación']);
}
