class ApiEndpoints {
  // Base URL
  static const String baseUrl = 'https://u-n8n.virtalus.cbluna-dev.com/webhook';
  static const String supabaseBaseUrl = 'https://u-supabase.virtalus.cbluna-dev.com/rest/v1/rpc';
  
  // Auth endpoints
  static const String resetPassword = '$baseUrl/uwifi_customer_reset_password';
  
  // Gateway endpoints
  static const String gatewayUsageInfo = '$baseUrl/uwifi_gateway_zequence_info_usage';
  static const String trafficInformation = '$supabaseBaseUrl/get_traffic_information';
  
  // Billing endpoints
  static const String updateAutomaticCharge = '$supabaseBaseUrl/update_automatic_charge';
}
