import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final int noteId;
  final DateTime createdAt;
  final String content;
  final int customerFk;

  const Note({
    required this.noteId,
    required this.createdAt,
    required this.content,
    required this.customerFk,
  });

  @override
  List<Object?> get props => [noteId, createdAt, content, customerFk];
}
