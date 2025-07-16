import 'package:uwifiapp/features/home/domain/entities/device_variable.dart';

class DeviceVariableModel extends DeviceVariable {
  const DeviceVariableModel({
    required super.variableName,
    required super.value,
  });

  factory DeviceVariableModel.fromJson(Map<String, dynamic> json) {
    return DeviceVariableModel(
      variableName: json['variable_name'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'variable_name': variableName, 'value': value};
  }
}
