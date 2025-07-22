import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Keys for WiFi passwords
  static const String _wifi24GPasswordKey = 'wifi_24g_password';
  static const String _wifi5GPasswordKey = 'wifi_5g_password';
  static const String _serialNumberKey = 'gateway_serial_number';

  // Save WiFi 2.4GHz password
  Future<void> saveWifi24GPassword(String password) async {
    await _secureStorage.write(key: _wifi24GPasswordKey, value: password);
  }

  // Get WiFi 2.4GHz password
  Future<String?> getWifi24GPassword() async {
    return await _secureStorage.read(key: _wifi24GPasswordKey);
  }

  // Save WiFi 5GHz password
  Future<void> saveWifi5GPassword(String password) async {
    await _secureStorage.write(key: _wifi5GPasswordKey, value: password);
  }

  // Get WiFi 5GHz password
  Future<String?> getWifi5GPassword() async {
    return await _secureStorage.read(key: _wifi5GPasswordKey);
  }

  // Save gateway serial number
  Future<void> saveGatewaySerialNumber(String serialNumber) async {
    await _secureStorage.write(key: _serialNumberKey, value: serialNumber);
  }

  // Get gateway serial number
  Future<String?> getGatewaySerialNumber() async {
    return await _secureStorage.read(key: _serialNumberKey);
  }

  // Delete all passwords (useful for logout)
  Future<void> clearAllPasswords() async {
    await _secureStorage.delete(key: _wifi24GPasswordKey);
    await _secureStorage.delete(key: _wifi5GPasswordKey);
    await _secureStorage.delete(key: _serialNumberKey);
  }
}
