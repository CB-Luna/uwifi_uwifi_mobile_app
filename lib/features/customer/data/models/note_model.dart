import '../../domain/entities/note.dart';

class NoteModel extends Note {
  const NoteModel({
    required super.noteId,
    required super.createdAt,
    required super.content,
    required super.customerFk,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      noteId: json['note_id'],
      createdAt: DateTime.parse(json['created_at']),
      content: json['content'],
      customerFk: json['customer_fk'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'note_id': noteId,
      'created_at': createdAt.toIso8601String(),
      'content': content,
      'customer_fk': customerFk,
    };
  }
}
