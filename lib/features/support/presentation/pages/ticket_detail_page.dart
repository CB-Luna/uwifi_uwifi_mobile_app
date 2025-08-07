import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/support_ticket.dart';
import 'image_viewer_page.dart';

class TicketDetailPage extends StatelessWidget {
  final SupportTicket ticket;

  const TicketDetailPage({required this.ticket, super.key});

  @override
  Widget build(BuildContext context) {
    // Formatear la fecha de creación
    String formattedDate = '';
    if (ticket.createdAt != null) {
      try {
        final DateTime dateTime = DateTime.parse(ticket.createdAt!);
        formattedDate = DateFormat(
          'MMM dd, yyyy \'at\' h:mm a',
        ).format(dateTime);
      } catch (e) {
        formattedDate = ticket.createdAt ?? '';
      }
    }

    // Determinar el estado del ticket y su color
    String statusText = 'Active';
    Color statusColor = Colors.blue;

    switch (ticket.status?.toLowerCase() ?? '') {
      case 'active':
        statusText = 'Active';
        statusColor = Colors.blue;
        break;
      case 'in progress':
        statusText = 'In Progress';
        statusColor = Colors.orange;
        break;
      case 'resolved':
        statusText = 'Resolved';
        statusColor = Colors.green;
        break;
      default:
        statusText = 'Active';
        statusColor = Colors.blue;
    }

    // Calcular el progreso basado en el estado
    // Primer paso siempre completado
    final progressStep2 = ticket.status?.toLowerCase() == 'in progress'
        ? 0.66
        : 0.33;
    final progressStep3 = ticket.status?.toLowerCase() == 'resolved'
        ? 1.0
        : progressStep2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección de estado del ticket
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: Colors.white,
              child: Column(
                children: [
                  // Icono de estado
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getStatusIcon(statusText),
                      color: statusColor,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Texto de estado
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Fecha
                  Text(
                    formattedDate,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  // Asignado a
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        ticket.assignedTo != null &&
                                ticket.assignedTo!.isNotEmpty
                            ? Icons.person
                            : Icons.person_search,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        ticket.assignedTo != null &&
                                ticket.assignedTo!.isNotEmpty
                            ? 'Assigned to ${ticket.assignedTo}'
                            : 'Someone will pick it up soon',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Barra de progreso
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: progressStep2 > 0.33
                                ? Colors.green
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: progressStep3 >= 0.9
                                ? Colors.green
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Sección de notificación
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'You will be notified here and by email',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, authState) {
                            // Obtener el email del usuario autenticado
                            final String email = authState is AuthAuthenticated
                                ? authState.user.email
                                : ticket.customerName;

                            return Text(
                              email,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.notifications, color: Colors.black54),
                ],
              ),
            ),

            // Detalles del ticket
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailItem('Ticket Type', ticket.type),
                  _buildDetailItem('Ticket ID', '#${ticket.id}'),
                  _buildDetailItem('Ticket Date', formattedDate),
                  _buildDetailItem('Category', ticket.category),
                  _buildDetailItem('Description', ticket.description),

                  // Mostrar imágenes adjuntas si existen
                  if (ticket.files != null && ticket.files!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Attached Media',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: ticket.files!.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () {
                                // Navegar a la pantalla de visualización de imágenes
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ImageViewerPage(
                                      imageUrl: ticket.files![index],
                                      title: 'Imagen ${index + 1}',
                                    ),
                                  ),
                                );
                              },
                              child: Hero(
                                tag: 'ticket_image_${ticket.id}_$index',
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    ticket.files![index],
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 100,
                                        height: 100,
                                        color: Colors.grey.shade300,
                                        child: const Icon(Icons.broken_image),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String title, String? content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(content ?? '', style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Icons.notifications_active;
      case 'in progress':
        return Icons.access_time;
      case 'resolved':
        return Icons.check_circle;
      default:
        return Icons.notifications_active;
    }
  }
}
