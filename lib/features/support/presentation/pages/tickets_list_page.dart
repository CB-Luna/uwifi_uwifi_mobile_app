import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';

import '../../../../core/presentation/widgets/loading_indicator.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../profile/presentation/widgets/settings/submit_ticket_page.dart';
import '../../domain/entities/support_ticket.dart';
import '../bloc/tickets_list_bloc.dart';
import '../bloc/tickets_list_event.dart';
import '../bloc/tickets_list_state.dart';
import 'ticket_detail_page.dart';

class TicketsListPage extends StatefulWidget {
  const TicketsListPage({super.key});

  @override
  State<TicketsListPage> createState() => _TicketsListPageState();
}

class _TicketsListPageState extends State<TicketsListPage> {
  // Variable para controlar el orden de los tickets
  bool _newestFirst = true;
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
          // Toggle switch animado para ordenar tickets
          Container(
            width: 150,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: AnimatedToggleSwitch<bool>.dual(
              current: _newestFirst,
              first: false,
              second: true,
              spacing: 10.0,
              height: 38,
              borderWidth: 1.0,
              style: ToggleStyle(
                borderColor: Colors.grey[300],
                backgroundColor: Colors.grey[100]!,
                borderRadius: BorderRadius.circular(10.0),
                indicatorBorderRadius: BorderRadius.circular(8.0),
                indicatorColor: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    spreadRadius: 0.5,
                    blurRadius: 1.5,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              iconBuilder: (value) => Transform(
                transform: value
                    ? Matrix4.rotationX(3.14159) // Invertir para Newest
                    : Matrix4.identity(), // Normal para Oldest
                alignment: Alignment.center,
                child: Icon(
                  Icons.sort,
                  size: 20,
                  color: Colors.grey[700],
                ),
              ),
              textBuilder: (value) => value
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'Newest',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'Oldest',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
              onChanged: (value) {
                setState(() {
                  _newestFirst = value;
                });
              },
            ),
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
    // Ordenar los tickets según la selección del usuario
    final sortedTickets = List<SupportTicket>.from(tickets);
    sortedTickets.sort((a, b) {
      // Convertir las fechas de string a DateTime para comparar
      final dateA = a.createdAt != null ? DateTime.parse(a.createdAt!) : DateTime(1970);
      final dateB = b.createdAt != null ? DateTime.parse(b.createdAt!) : DateTime(1970);
      
      // Si _newestFirst es true, ordenar de más reciente a más antiguo (b comparado con a)
      // Si _newestFirst es false, ordenar de más antiguo a más reciente (a comparado con b)
      return _newestFirst ? dateB.compareTo(dateA) : dateA.compareTo(dateB);
    });
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedTickets.length,
      itemBuilder: (context, index) {
        final ticket = sortedTickets[index];
        return _TicketCard(ticket: ticket);
      },
    );
  }
}

class _TicketCard extends StatelessWidget {
  final SupportTicket ticket;

  const _TicketCard({required this.ticket});

  // Formatea la fecha para mostrarla en formato legible
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'No date';
    }

    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determinar el color y texto del estado
    Color statusColor;
    String statusText;
    Color badgeColor;

    switch (ticket.status?.toLowerCase() ?? 'created') {
      case 'active':
        statusColor = Colors.blue;
        statusText = 'Active';
        badgeColor = Colors.blue.shade100;
        break;
      case 'in progress':
        statusColor = Colors.orange;
        statusText = 'In Progress';
        badgeColor = Colors.orange.shade100;
        break;
      default:
        statusColor = Colors.green;
        statusText = 'Resolved';
        badgeColor = Colors.green.shade100;
    }

    // Formatear la fecha para mostrarla
    String formattedDate = _formatDate(ticket.createdAt);

    return GestureDetector(
      onTap: () {
        // Navegar a la página de detalles al hacer tap
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TicketDetailPage(ticket: ticket),
          ),
        );
      },
      child: Card(
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
      ),
    );
  }
}
