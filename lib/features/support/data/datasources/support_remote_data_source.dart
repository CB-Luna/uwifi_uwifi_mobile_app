import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/support_ticket_model.dart';

abstract class SupportRemoteDataSource {
  /// Crea un ticket de soporte
  /// Throws [ServerException] si hay un error en el servidor
  Future<void> createSupportTicket(SupportTicketModel ticket);
  
  /// Sube archivos para un ticket de soporte
  /// Throws [ServerException] si hay un error en el servidor
  Future<List<String>> uploadTicketFiles(List<dynamic> files);
  
  /// Obtiene las categorías de tickets disponibles
  /// Throws [ServerException] si hay un error en el servidor
  Future<List<dynamic>> getTicketCategories();
  
  /// Obtiene los tickets de un cliente específico
  /// Throws [ServerException] si hay un error en el servidor
  Future<List<SupportTicketModel>> getCustomerTickets({
    required int customerId,
    String? status,
  });
}

class SupportRemoteDataSourceImpl implements SupportRemoteDataSource {
  final http.Client client;

  SupportRemoteDataSourceImpl({required this.client});

  @override
  Future<void> createSupportTicket(SupportTicketModel ticket) async {
    final response = await client.post(
      Uri.parse(ApiEndpoints.createSupportTicket),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(ticket.toJson()),
    );

    if (response.statusCode != 200) {
      throw ServerException('Error creating support ticket: ${response.body}');
    }
  }

  @override
  Future<List<String>> uploadTicketFiles(List files) async {
    // Implementación para subir archivos
    // Esta es una implementación simplificada
    try {
      // Simulamos una respuesta exitosa con URLs de archivos
      return ['https://example.com/file1.jpg', 'https://example.com/file2.jpg'];
    } catch (e) {
      throw ServerException('Error uploading files: $e');
    }
  }

  @override
  Future<List> getTicketCategories() async {
    final response = await client.get(
      Uri.parse(ApiEndpoints.ticketCategories),
    );

    if (response.statusCode != 200) {
      throw ServerException('Error getting ticket categories: ${response.body}');
    }

    return jsonDecode(response.body) as List;
  }

  @override
  Future<List<SupportTicketModel>> getCustomerTickets({
    required int customerId,
    String? status,
  }) async {
    // Construir la URL con parámetros
    final queryParams = {'customer_id': customerId.toString()};
    if (status != null) {
      queryParams['status'] = status;
    }

    final uri = Uri.parse(ApiEndpoints.customerTickets).replace(
      queryParameters: queryParams,
    );

    final response = await client.get(uri);

    if (response.statusCode != 200) {
      throw ServerException('Error getting customer tickets: ${response.body}');
    }

    final List<dynamic> ticketsJson = jsonDecode(response.body) as List;
    return ticketsJson
        .map((ticketJson) => SupportTicketModel.fromJson(ticketJson))
        .toList();
  }
}
