import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../customer/domain/entities/customer_details.dart';
import '../entities/referral.dart';

/// Repositorio abstracto para manejar invitaciones y referidos
abstract class InviteRepository {
  /// Obtiene la información del referido del usuario actual
  /// [customerDetails] Detalles del cliente para usar el sharedLinkId como código de referido
  Future<Either<Failure, Referral>> getUserReferral({CustomerDetails? customerDetails});
  
  /// Genera un nuevo código de referido para el usuario
  Future<Either<Failure, Referral>> generateReferralCode();
  
  /// Comparte el enlace de referido
  Future<Either<Failure, bool>> shareReferralLink(String referralLink);
  
  /// Genera un código QR para el enlace de referido
  Future<Either<Failure, String>> generateQRCode(String referralLink);
  
  /// Obtiene las estadísticas de referidos del usuario
  Future<Either<Failure, Map<String, dynamic>>> getReferralStats();
}
