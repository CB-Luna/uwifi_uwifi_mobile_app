class ApiEndpoints {
  // Base URL
  static const String baseUrl = 'https://u-n8n.virtalus.cbluna-dev.com/webhook';
  static const String supabaseBaseUrl = 'https://u-supabase.virtalus.cbluna-dev.com/rest/v1/rpc';
  static const String zequenceBaseUrl = 'https://control-dev.zequenze.com/api/v1';
  static const String airflowBaseUrl = 'https://u-airflow.virtalus.cbluna-dev.com/uapi';
  
  // Auth endpoints
  static const String resetPassword = '$baseUrl/uwifi_customer_reset_password';
  
  // Gateway endpoints
  static const String gatewayInfo = '$baseUrl/uwifi_gateway_zequence_info';
  static const String gatewayUsageInfo = '$baseUrl/uwifi_gateway_zequence_info_usage';
  static const String trafficInformation = '$supabaseBaseUrl/get_traffic_information';
  static const String deviceVariables = '$zequenceBaseUrl/inventory_device_serial_variables';
  
  // Billing endpoints
  static const String updateAutomaticCharge = '$supabaseBaseUrl/update_automatic_charge';
  
  // Payment endpoints
  static const String updateDefaultCreditCard = '$airflowBaseUrl/update-default-creditcard';
  static const String deleteCreditCard = '$airflowBaseUrl/delete-credit-card';
  
  // API Keys
  static const String zequenceApiKey = 'd43bdbe46e77d09ef9674c240deb7cd0597d3aae';
}
