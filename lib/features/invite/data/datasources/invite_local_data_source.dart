/// Data source abstracto para manejar funciones locales de invitación
abstract class InviteLocalDataSource {
  /// Comparte el enlace de referido usando el sistema nativo
  Future<bool> shareReferralLink(String referralLink);
  
  /// Genera un código QR para el enlace de referido
  Future<String> generateQRCode(String referralLink);
}
