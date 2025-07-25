import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/support_ticket.dart';

abstract class SupportTicketRepository {
  /// Crea un ticket de soporte
  Future<Either<Failure, void>> createSupportTicket(SupportTicket ticket);

  /// Sube archivos para un ticket de soporte y devuelve las URLs
  Future<Either<Failure, List<String>>> uploadTicketFiles(List<File> files);
}
