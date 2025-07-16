import 'package:equatable/equatable.dart';

class DeviceVariable extends Equatable {
  final String variableName;
  final String value;

  const DeviceVariable({
    required this.variableName,
    required this.value,
  });

  @override
  List<Object?> get props => [variableName, value];
}
