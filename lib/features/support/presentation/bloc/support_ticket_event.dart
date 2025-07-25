import 'dart:io';

import 'package:equatable/equatable.dart';

import '../../domain/entities/support_ticket.dart';

abstract class SupportTicketEvent extends Equatable {
  const SupportTicketEvent();

  @override
  List<Object?> get props => [];
}

class UploadTicketFilesEvent extends SupportTicketEvent {
  final List<File> files;

  const UploadTicketFilesEvent(this.files);

  @override
  List<Object?> get props => [files];
}

class CreateSupportTicketEvent extends SupportTicketEvent {
  final SupportTicket ticket;

  const CreateSupportTicketEvent(this.ticket);

  @override
  List<Object?> get props => [ticket];
}
