import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/support_ticket.dart';
import '../models/support_ticket_model.dart';
import 'support_ticket_remote_data_source.dart';

class SupportTicketRemoteDataSourceImpl implements SupportTicketRemoteDataSource {
  final SupabaseClient supabaseClient;
  static const String _bucketName = 'support_tickets_file';
  static const String _folderPath = 'ticket_images';
  static const String _tableName = 'support_tickets';

  SupportTicketRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<void> createSupportTicket(SupportTicket ticket) async {
    try {
      final ticketModel = ticket is SupportTicketModel
          ? ticket
          : SupportTicketModel(
              customerName: ticket.customerName,
              category: ticket.category,
              type: ticket.type,
              description: ticket.description,
              customerId: ticket.customerId,
              files: ticket.files,
            );

      await supabaseClient.from(_tableName).insert(ticketModel.toJson());
      AppLogger.navInfo('Support ticket created successfully');
    } catch (e) {
      AppLogger.navError('Error creating support ticket: $e');
      throw ServerException('Error creating support ticket: $e');
    }
  }

  @override
  Future<List<String>> uploadTicketFiles(List<File> files) async {
    try {
      final List<String> fileUrls = [];

      for (final file in files) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
        final filePath = '$_folderPath/$fileName';

        final response = await supabaseClient.storage
            .from(_bucketName)
            .upload(filePath, file);

        AppLogger.navInfo('File uploaded successfully: $response');

        // Obtener la URL pública del archivo
        final String fileUrl = supabaseClient.storage
            .from(_bucketName)
            .getPublicUrl(filePath);

        fileUrls.add(fileUrl);
      }

      return fileUrls;
    } catch (e) {
      AppLogger.navError('Error uploading files: $e');
      throw ServerException('Error uploading files: $e');
    }
  }
}
