class ApiEndpoints {
  // Base URL
  static const String baseUrl = 'https://u-n8n.virtalus.cbluna-dev.com/webhook';
  
  // Auth endpoints
  static const String resetPassword = '$baseUrl/uwifi_customer_reset_password';
  
  // Gateway endpoints
  static const String gatewayUsageInfo = '$baseUrl/uwifi_gateway_zequence_info_usage';
}
