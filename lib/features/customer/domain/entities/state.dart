import 'package:equatable/equatable.dart';

class State extends Equatable {
  final int stateId;
  final DateTime createdAt;
  final String code;
  final String name;

  const State({
    required this.stateId,
    required this.createdAt,
    required this.code,
    required this.name,
  });

  @override
  List<Object?> get props => [stateId, createdAt, code, name];
}
