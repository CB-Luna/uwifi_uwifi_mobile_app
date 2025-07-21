import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, User?>> getCurrentUser();

  Future<Either<Failure, bool>> isUserLoggedIn();
  
  Future<Either<Failure, void>> resetPassword(String email);
  
  /// Obtiene un usuario por su email
  /// Útil para autenticación biométrica donde ya tenemos el email guardado
  Future<Either<Failure, User?>> getUserByEmail(String email);
}
