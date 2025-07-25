import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/usecases/create_support_ticket.dart';
import '../../domain/usecases/upload_ticket_files.dart';
import 'support_ticket_event.dart';
import 'support_ticket_state.dart';

class SupportTicketBloc extends Bloc<SupportTicketEvent, SupportTicketState> {
  final UploadTicketFiles uploadTicketFiles;
  final CreateSupportTicket createSupportTicket;

  SupportTicketBloc({
    required this.uploadTicketFiles,
    required this.createSupportTicket,
  }) : super(const SupportTicketInitial()) {
    on<UploadTicketFilesEvent>(_onUploadTicketFiles);
    on<CreateSupportTicketEvent>(_onCreateSupportTicket);
  }

  Future<void> _onUploadTicketFiles(
    UploadTicketFilesEvent event,
    Emitter<SupportTicketState> emit,
  ) async {
    emit(const FilesUploading());

    final result = await uploadTicketFiles(UploadFilesParams(event.files));

    result.fold(
      (failure) {
        final message = _mapFailureToMessage(failure);
        AppLogger.navError('Error uploading files: $message');
        emit(SupportTicketError(message));
      },
      (fileUrls) {
        AppLogger.navInfo('Files uploaded successfully: $fileUrls');
        emit(FilesUploaded(fileUrls));
      },
    );
  }

  Future<void> _onCreateSupportTicket(
    CreateSupportTicketEvent event,
    Emitter<SupportTicketState> emit,
  ) async {
    emit(const SupportTicketLoading());

    final result = await createSupportTicket(SupportTicketParams(event.ticket));

    result.fold(
      (failure) {
        final message = _mapFailureToMessage(failure);
        AppLogger.navError('Error creating support ticket: $message');
        emit(SupportTicketError(message));
      },
      (_) {
        AppLogger.navInfo('Support ticket created successfully');
        emit(const SupportTicketCreated());
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case const (ServerFailure):
        return (failure as ServerFailure).message;
      case const (NetworkFailure):
        return 'Please check your internet connection';
      default:
        return 'Unexpected error';
    }
  }
}
