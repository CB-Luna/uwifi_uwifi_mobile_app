import 'package:equatable/equatable.dart';

abstract class SupportTicketState extends Equatable {
  const SupportTicketState();

  @override
  List<Object?> get props => [];
}

class SupportTicketInitial extends SupportTicketState {
  const SupportTicketInitial();
}

class SupportTicketLoading extends SupportTicketState {
  const SupportTicketLoading();
}

class FilesUploading extends SupportTicketState {
  const FilesUploading();
}

class FilesUploaded extends SupportTicketState {
  final List<String> fileUrls;

  const FilesUploaded(this.fileUrls);

  @override
  List<Object?> get props => [fileUrls];
}

class SupportTicketCreated extends SupportTicketState {
  const SupportTicketCreated();
}

class SupportTicketError extends SupportTicketState {
  final String message;

  const SupportTicketError(this.message);

  @override
  List<Object?> get props => [message];
}
