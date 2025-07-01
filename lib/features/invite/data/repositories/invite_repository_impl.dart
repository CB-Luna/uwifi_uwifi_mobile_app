import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/referral.dart';
import '../../domain/repositories/invite_repository.dart';
import '../datasources/invite_remote_data_source.dart';
import '../datasources/invite_local_data_source.dart';

/// Implementación del repositorio de invitaciones
class InviteRepositoryImpl implements InviteRepository {
  final InviteRemoteDataSource remoteDataSource;
  final InviteLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  InviteRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Referral>> getUserReferral() async {
    debugPrint('🌐 InviteRepository: Verificando conexión...');
    if (await networkInfo.isConnected) {
      debugPrint('✅ InviteRepository: Conexión disponible, consultando remoto...');
      try {
        final referral = await remoteDataSource.getUserReferral();
        debugPrint('✅ InviteRepository: Referido obtenido exitosamente');
        return Right(referral);
      } on ServerException catch (e) {
        debugPrint('❌ InviteRepository: ServerException capturada: $e');
        return const Left(ServerFailure());
      } catch (e) {
        debugPrint('💥 InviteRepository: Excepción no esperada: $e');
        return const Left(ServerFailure());
      }
    } else {
      debugPrint('❌ InviteRepository: Sin conexión a internet');
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Referral>> generateReferralCode() async {
    if (await networkInfo.isConnected) {
      try {
        final referral = await remoteDataSource.generateReferralCode();
        return Right(referral);
      } on ServerException {
        return const Left(ServerFailure());
      }
    } else {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> shareReferralLink(String referralLink) async {
    try {
      final result = await localDataSource.shareReferralLink(referralLink);
      return Right(result);
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, String>> generateQRCode(String referralLink) async {
    try {
      final qrData = await localDataSource.generateQRCode(referralLink);
      return Right(qrData);
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getReferralStats() async {
    if (await networkInfo.isConnected) {
      try {
        final stats = await remoteDataSource.getReferralStats();
        return Right(stats);
      } on ServerException {
        return const Left(ServerFailure());
      }
    } else {
      return const Left(ServerFailure());
    }
  }
}
