import '../../domain/entities/state.dart';

class StateModel extends State {
  const StateModel({
    required super.stateId,
    required super.createdAt,
    required super.code,
    required super.name,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      stateId: json['state_id'],
      createdAt: DateTime.parse(json['created_at']),
      code: json['code'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': stateId,
      'name': name,
      'code': code,
    };
  }
  
  Map<String, dynamic> toJson() => toMap();
}
