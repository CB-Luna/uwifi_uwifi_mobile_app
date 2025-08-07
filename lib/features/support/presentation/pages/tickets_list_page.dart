import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/presentation/widgets/loading_indicator.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../profile/presentation/widgets/settings/submit_ticket_page.dart';
import '../../domain/entities/support_ticket.dart';
import '../bloc/tickets_list_bloc.dart';
import '../bloc/tickets_list_event.dart';
import '../bloc/tickets_list_state.dart';

class TicketsListPage extends StatefulWidget {
  const TicketsListPage({super.key});

  @override
  State<TicketsListPage> createState() => _TicketsListPageState();
}

class _TicketsListPageState extends State<TicketsListPage> {
  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  void _loadTickets() {
    final authBloc = context.read<AuthBloc>();
    final authState = authBloc.state;

    if (authState is AuthAuthenticated && authState.user.customerId != null) {
      final customerId = authState.user.customerId!;
      context.read<TicketsListBloc>().add(LoadTicketsEvent(customerId));
    } else {
      AppLogger.navError('Usuario no autenticado o sin customerId');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tickets',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Implementar filtrado de tickets
            },
          ),
        ],
      ),
      body: BlocBuilder<TicketsListBloc, TicketsListState>(
        builder: (context, state) {
          if (state is TicketsListLoading) {
            return const Center(child: LoadingIndicator());
          } else if (state is TicketsListLoaded) {
            if (state.tickets.isEmpty) {
              return _buildEmptyState();
            }
            return _buildTicketsList(state.tickets);
          } else if (state is TicketsListError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadTickets,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          return _buildEmptyState();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Verificamos si podemos obtener el AuthBloc del contexto actual
          try {
            final authBloc = BlocProvider.of<AuthBloc>(context);
            AppLogger.navInfo(
              'TicketsListPage: Estado de AuthBloc: ${authBloc.state.runtimeType}',
            );

            Navigator.of(context)
                .push(
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: authBloc,
                      child: const SubmitTicketPageProvider(),
                    ),
                  ),
                )
                .then((_) {
                  // Recargar la lista de tickets cuando regresemos
                  _loadTickets();
                });
          } catch (e) {
            AppLogger.navError(
              'Error al obtener AuthBloc en TicketsListPage: $e',
            );
            // Si no podemos obtener el AuthBloc, mostramos un mensaje de error
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Error: No se pudo acceder a la información de autenticación',
                ),
              ),
            );
          }
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.support_agent, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No tienes tickets activos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Crea un nuevo ticket para recibir ayuda',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              try {
                final authBloc = BlocProvider.of<AuthBloc>(context);
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (context) => BlocProvider.value(
                          value: authBloc,
                          child: const SubmitTicketPageProvider(),
                        ),
                      ),
                    )
                    .then((_) => _loadTickets());
              } catch (e) {
                AppLogger.navError('Error al navegar: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error al crear ticket')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Crear ticket'),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketsList(List<SupportTicket> tickets) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        final ticket = tickets[index];
        return _TicketCard(ticket: ticket);
      },
    );
  }
}

class _TicketCard extends StatelessWidget {
  final SupportTicket ticket;

  const _TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    // Determinar el color de la barra lateral y el badge según el estado
    Color statusColor;
    String statusText;
    Color badgeColor;

    switch (ticket.status?.toLowerCase() ?? 'created') {
      case 'active':
        statusColor = Colors.green;
        statusText = 'Active';
        badgeColor = Colors.green.shade100;
        break;
      case 'in progress':
        statusColor = Colors.orange;
        statusText = 'In Progress';
        badgeColor = Colors.orange.shade100;
        break;
      default:
        statusColor = Colors.blue;
        statusText = 'Resolved';
        badgeColor = Colors.blue.shade100;
    }

    // Formatear la fecha
    String formattedDate = '';
    if (ticket.createdAt != null) {
      try {
        final date = DateTime.parse(ticket.createdAt!);
        formattedDate = DateFormat('MMM dd, yyyy').format(date);
      } catch (e) {
        formattedDate = ticket.createdAt ?? '';
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Barra lateral de color según estado
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            // Contenido principal
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ID y estado
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '#${ticket.id ?? '000'}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Título
                    Text(
                      ticket.type,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Información adicional
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          ticket.assignedTo != null &&
                                  ticket.assignedTo!.isNotEmpty
                              ? 'Assigned to ${ticket.assignedTo}'
                              : 'Waiting for Assignment',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Fecha
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
