/// Excepción cuando ocurre un error en el servidor
class ServerException implements Exception {}

/// Excepción cuando ocurre un error en la caché local
class CacheException implements Exception {}

/// Excepción cuando no se puede establecer conexión a internet
class NetworkException implements Exception {}

/// Excepción cuando no se encuentra un recurso solicitado
class NotFoundException implements Exception {}

/// Excepción cuando un usuario no está autenticado
class UnauthorizedException implements Exception {}
