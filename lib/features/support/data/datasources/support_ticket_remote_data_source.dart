import 'dart:io';

import '../../domain/entities/support_ticket.dart';

abstract class SupportTicketRemoteDataSource {
  /// Crea un ticket de soporte en el servidor
  ///
  /// Throws [ServerException] si ocurre un error en el servidor
  Future<void> createSupportTicket(SupportTicket ticket);

  /// Sube archivos para un ticket de soporte y devuelve las URLs
  ///
  /// Throws [ServerException] si ocurre un error en el servidor
  Future<List<String>> uploadTicketFiles(List<File> files);
}
