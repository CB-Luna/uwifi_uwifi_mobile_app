import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Claves para las contraseñas WiFi
  static const String _wifi24GPasswordKey = 'wifi_24g_password';
  static const String _wifi5GPasswordKey = 'wifi_5g_password';
  static const String _serialNumberKey = 'gateway_serial_number';

  // Guardar contraseña WiFi 2.4GHz
  Future<void> saveWifi24GPassword(String password) async {
    await _secureStorage.write(key: _wifi24GPasswordKey, value: password);
  }

  // Obtener contraseña WiFi 2.4GHz
  Future<String?> getWifi24GPassword() async {
    return await _secureStorage.read(key: _wifi24GPasswordKey);
  }

  // Guardar contraseña WiFi 5GHz
  Future<void> saveWifi5GPassword(String password) async {
    await _secureStorage.write(key: _wifi5GPasswordKey, value: password);
  }

  // Obtener contraseña WiFi 5GHz
  Future<String?> getWifi5GPassword() async {
    return await _secureStorage.read(key: _wifi5GPasswordKey);
  }

  // Guardar número de serie del gateway
  Future<void> saveGatewaySerialNumber(String serialNumber) async {
    await _secureStorage.write(key: _serialNumberKey, value: serialNumber);
  }

  // Obtener número de serie del gateway
  Future<String?> getGatewaySerialNumber() async {
    return await _secureStorage.read(key: _serialNumberKey);
  }

  // Eliminar todas las contraseñas (útil para logout)
  Future<void> clearAllPasswords() async {
    await _secureStorage.delete(key: _wifi24GPasswordKey);
    await _secureStorage.delete(key: _wifi5GPasswordKey);
    await _secureStorage.delete(key: _serialNumberKey);
  }
}
