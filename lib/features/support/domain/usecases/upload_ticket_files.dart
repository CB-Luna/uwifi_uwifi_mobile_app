import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/support_ticket_repository.dart';

class UploadTicketFiles implements UseCase<List<String>, UploadFilesParams> {
  final SupportTicketRepository repository;

  UploadTicketFiles(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(UploadFilesParams params) {
    return repository.uploadTicketFiles(params.files);
  }
}

class UploadFilesParams {
  final List<File> files;

  UploadFilesParams(this.files);
}
