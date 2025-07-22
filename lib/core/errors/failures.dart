import 'package:equatable/equatable.dart';

/// Base class for all failures
abstract class Failure extends Equatable {
  final String message;

  const Failure([this.message = '']);

  @override
  List<Object?> get props => [message];
}

/// Failure when an error occurs on the server
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error']);
}

/// Failure when an error occurs in the local cache
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error']);
}

/// Failure when there is no internet connection
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

/// Failure when a requested resource is not found
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found']);
}

/// Failure when a user is not authenticated
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'User not authorized']);
}

/// Failure during the authentication process
class AuthenticationFailure extends Failure {
  const AuthenticationFailure([super.message = 'Authentication error']);
}

/// Alias for AuthenticationFailure to maintain compatibility
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication error']);
}
