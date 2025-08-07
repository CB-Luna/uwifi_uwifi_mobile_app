import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/app_logger.dart';
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
  final SupabaseClient supabaseClient;

  SupportRemoteDataSourceImpl({
    required this.client,
    required this.supabaseClient,
  });

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
    final response = await client.post(
      Uri.parse(ApiEndpoints.ticketCategories),
    );

    if (response.statusCode != 200) {
      throw ServerException(
        'Error getting ticket categories: ${response.body}',
      );
    }

    return jsonDecode(response.body) as List;
  }

  @override
  Future<List<SupportTicketModel>> getCustomerTickets({
    required int customerId,
    String? status,
  }) async {
    try {
      AppLogger.navInfo(
        'Getting tickets for customerId: $customerId, status: $status',
      );

      // Preparar los parámetros para la función RPC
      final params = {'p_customer_id': customerId};
      
      // Si se especifica un estado, agregarlo a la consulta (esto requeriría modificar la función RPC)
      // Por ahora, filtramos después de obtener los resultados
      
      // Llamar a la función RPC
      final response = await supabaseClient.rpc(
        'get_customer_tickets',
        params: params,
      );

      AppLogger.navInfo('Response received: $response');

      if (response == null) {
        AppLogger.navError('Error getting customer tickets: null response');
        throw ServerException('Error getting customer tickets: null response');
      }

      // Convertir la respuesta a una lista de SupportTicketModel
      final List<dynamic> ticketsJson = response as List;
      
      // Filtrar por estado si se especificó
      final filteredTickets = status != null
          ? ticketsJson.where((ticket) => ticket['status'] == status).toList()
          : ticketsJson;
          
      return filteredTickets.map((ticketJson) {
        // Manejar el campo 'file' que puede ser null, string vacío o array
        var files = ticketJson['file'];
        List<String>? filesList;
        
        if (files != null && files is List) {
          filesList = List<String>.from(files);
        } else if (files is String && files.isNotEmpty) {
          filesList = [files];
        }
        
        // Crear un mapa con las claves correctas para el modelo
        final Map<String, dynamic> mappedJson = {
          'id': ticketJson['ticket_id'],
          'customer_name': ticketJson['customer_name'],
          'category': ticketJson['category'],
          'type': ticketJson['type'],
          'description': ticketJson['description'],
          'customer_id_fk': ticketJson['customer_id_fk'],
          'file': filesList,
          'created_at': ticketJson['created_at'],
          'status': ticketJson['status'],
          'title': null, // No parece estar en la respuesta
          'assigned_to': ticketJson['agent_name'],
        };
        
        return SupportTicketModel.fromJson(mappedJson);
      }).toList();
    } catch (e) {
      AppLogger.navError('Error getting customer tickets: $e');
      throw ServerException('Error getting customer tickets: $e');
    }
  }
}
