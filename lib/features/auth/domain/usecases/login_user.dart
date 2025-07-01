import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUser implements UseCase<User, LoginParams> {
  final AuthRepository repository;

  LoginUser(this.repository);

  @override
  Future<Either<Failure, User>> call(LoginParams params) async {
    // Credenciales demo temporales
    if (params.email == 'demo@uwifi.com' && params.password == 'demo123') {
      final demoUser = User(
        id: 'demo-user-123',
        email: 'demo@uwifi.com',
        name: 'Usuario Demo',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      return Right(demoUser);
    }

    // Si no son las credenciales demo, usar Supabase
    return await repository.login(
      email: params.email,
      password: params.password,
    );
  }
}

class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}
