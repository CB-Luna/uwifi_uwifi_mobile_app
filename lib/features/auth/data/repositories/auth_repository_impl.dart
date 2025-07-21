import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.login(
          email: email,
          password: password,
        );
        await localDataSource.cacheUser(user);
        return Right(user);
      } catch (e) {
        return Left(AuthenticationFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearCache();
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      if (await networkInfo.isConnected) {
        final user = await remoteDataSource.getCurrentUser();
        if (user != null) {
          await localDataSource.cacheUser(user);
        }
        return Right(user);
      } else {
        final cachedUser = await localDataSource.getCachedUser();
        return Right(cachedUser);
      }
    } catch (e) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> isUserLoggedIn() async {
    try {
      final isLoggedIn = await remoteDataSource.isUserLoggedIn();
      return Right(isLoggedIn);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.resetPassword(email);
        return const Right(null);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
  
  @override
  Future<Either<Failure, User?>> getUserByEmail(String email) async {
    if (await networkInfo.isConnected) {
      try {
        // Intentamos obtener el usuario por email desde el remoteDataSource
        final user = await remoteDataSource.getUserByEmail(email);
        if (user != null) {
          // Si encontramos el usuario, lo guardamos en caché
          await localDataSource.cacheUser(user);
        }
        return Right(user);
      } catch (e) {
        return Left(AuthenticationFailure(e.toString()));
      }
    } else {
      // Si no hay conexión, intentamos obtener el usuario de la caché
      try {
        final cachedUser = await localDataSource.getCachedUser();
        // Solo devolvemos el usuario en caché si coincide con el email solicitado
        if (cachedUser != null && cachedUser.email == email) {
          return Right(cachedUser);
        } else {
          return const Right(null);
        }
      } catch (e) {
        return const Left(CacheFailure());
      }
    }
  }
}
