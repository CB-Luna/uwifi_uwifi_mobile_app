import 'package:share_plus/share_plus.dart';
import '../../../../core/errors/exceptions.dart';
import 'invite_local_data_source.dart';

/// Implementación del data source local para invitaciones
class InviteLocalDataSourceImpl implements InviteLocalDataSource {
  @override
  Future<bool> shareReferralLink(String referralLink) async {
    try {
      await Share.share(
        'Join U-wifi and get exclusive discounts! Use my referral link: $referralLink',
        subject: 'Join U-wifi - Get Discounts!',
      );
      
      // Share.share no retorna un resultado en la versión actual
      // Asumimos que fue exitoso si no lanzó una excepción
      return true;
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<String> generateQRCode(String referralLink) async {
    try {
      // Retornamos el link para que el widget QR lo procese
      // El widget QrImageView se encargará de generar el código QR visual
      return referralLink;
    } catch (e) {
      throw CacheException();
    }
  }
}
