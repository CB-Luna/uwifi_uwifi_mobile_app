import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../customer/domain/entities/customer_details.dart';
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
  Future<Either<Failure, Referral>> getUserReferral({CustomerDetails? customerDetails}) async {
    AppLogger.navInfo('InviteRepository: Verificando conexión...');
    if (await networkInfo.isConnected) {
      AppLogger.navInfo('InviteRepository: Conexión disponible, consultando remoto...');
      
      // Si tenemos customerDetails, registramos la información
      if (customerDetails != null) {
        AppLogger.navInfo(
          'InviteRepository: CustomerDetails proporcionado - customerId: ${customerDetails.customerId}, '
          'sharedLinkId: ${customerDetails.sharedLinkId}',
        );
      }
      
      try {
        // Pasamos el customerDetails al datasource
        final referral = await remoteDataSource.getUserReferral(customerDetails: customerDetails);
        AppLogger.navInfo('InviteRepository: Referido obtenido exitosamente');
        return Right(referral);
      } on ServerException catch (e) {
        AppLogger.navError('InviteRepository: ServerException capturada: $e');
        return const Left(ServerFailure());
      } catch (e) {
        AppLogger.navError('InviteRepository: Excepción no esperada: $e');
        return const Left(ServerFailure());
      }
    } else {
      AppLogger.navError('InviteRepository: Sin conexión a internet');
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
