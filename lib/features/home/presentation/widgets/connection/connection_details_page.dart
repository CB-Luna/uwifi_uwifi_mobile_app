import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uwifiapp/core/utils/app_logger.dart';
import 'package:uwifiapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:uwifiapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:uwifiapp/injection_container.dart' as di;

import '../../bloc/connection_bloc.dart';
import '../../bloc/connection_event.dart';
import '../../bloc/connection_state.dart' as connection_state;
import '../../bloc/data_usage_bloc.dart';
import '../../bloc/data_usage_event.dart';
import 'connected_devices_card.dart';
import 'data_usage_bar_chart.dart';
import 'data_usage_donut_chart.dart';
import 'wifi_settings_page.dart';

class ConnectionDetailsPage extends StatefulWidget {
  const ConnectionDetailsPage({super.key});

  @override
  State<ConnectionDetailsPage> createState() => _ConnectionDetailsPageState();
}

class _ConnectionDetailsPageState extends State<ConnectionDetailsPage> {
  bool showLast3Months = false;
  DateTime? lastToggleTime;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final user = authState.user;

      // Check if the user has customerId
      if (user.customerId != null) {
        AppLogger.navInfo(
          'Loading information for customerId: ${user.customerId}',
        );
        // Load usage data when initializing the page
        context.read<DataUsageBloc>().add(
          GetDataUsageEvent(customerId: user.customerId.toString()),
        );

        // Load connection information
        context.read<ConnectionBloc>().add(
          GetConnectionInfoEvent(user.customerId!),
        );
      } else {
        AppLogger.navError('Error: User does not have an assigned customerId');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connection Details'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with image, status, name and Settings button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 20,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Gateway image container
                  Container(
                    width: 90,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EAF6),
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Image.asset(
                        'assets/images/homeimage/realGateway.png',
                        fit: BoxFit.cover,
                        width: 90,
                        height: 120,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Right side content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        BlocBuilder<
                          ConnectionBloc,
                          connection_state.ConnectionState
                        >(
                          builder: (context, state) {
                            String connectionStatus = 'Loading...';
                            String wifiName = 'Searching...';
                            Color statusColor = Colors.grey;

                            if (state is connection_state.ConnectionLoaded) {
                              connectionStatus =
                                  state.gatewayInfo.connectionStatus;
                              wifiName = state.gatewayInfo.wifiName;
                              statusColor = connectionStatus == 'Connected'
                                  ? const Color(0xFF4CAF50)
                                  : Colors.red;
                            } else if (state
                                    is connection_state.ConnectionLoading &&
                                state.previousInfo != null) {
                              connectionStatus =
                                  state.previousInfo!.connectionStatus;
                              wifiName = state.previousInfo!.wifiName;
                              statusColor = connectionStatus == 'Connected'
                                  ? const Color(0xFF4CAF50)
                                  : Colors.red;
                            } else if (state
                                is connection_state.ConnectionError) {
                              connectionStatus = 'Error';
                              wifiName = 'No connection';
                              statusColor = Colors.red;
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  connectionStatus,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  wifiName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            // Get the customer ID from the authentication state
                            final authState = context.read<AuthBloc>().state;
                            if (authState is AuthAuthenticated &&
                                authState.user.customerId != null) {
                              final customerId = authState.user.customerId!;
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      BlocProvider<ConnectionBloc>(
                                        create: (_) {
                                          final bloc = di
                                              .getIt<ConnectionBloc>();
                                          bloc.add(
                                            GetConnectionInfoEvent(customerId),
                                          );
                                          return bloc;
                                        },
                                        child: const WifiSettingsPage(),
                                      ),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                            foregroundColor: Colors.black87,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            minimumSize: const Size(80, 30),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('Settings'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Card de Data Usage
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Data Usage',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 16),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          // Recargar los datos de uso forzando actualización
                          final authState = context.read<AuthBloc>().state;
                          if (authState is AuthAuthenticated && authState.user.customerId != null) {
                            context.read<DataUsageBloc>().add(
                              ForceRefreshDataUsageEvent(customerId: authState.user.customerId.toString()),
                            );
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.info_outline, size: 16),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('How Your Usage Is Tracked'),
                              content: const Text(
                                'Your billing cycle ends on May 8. Your usage is tracked based on your billing month, not the regular calendar month.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Ok'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Si ya está seleccionado, no hacemos nada
                            if (!showLast3Months) return;
                            
                            // Añadir debounce para evitar múltiples actualizaciones rápidas
                            final now = DateTime.now();
                            if (lastToggleTime == null ||
                                now.difference(lastToggleTime!).inMilliseconds > 500) {
                              setState(() {
                                showLast3Months = false;
                                lastToggleTime = now;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            backgroundColor: !showLast3Months
                                ? Colors.black
                                : Colors.grey.shade200,
                            foregroundColor: !showLast3Months
                                ? Colors.white
                                : Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'This Month',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Si ya está seleccionado, no hacemos nada
                            if (showLast3Months) return;
                            
                            // Añadir debounce para evitar múltiples actualizaciones rápidas
                            final now = DateTime.now();
                            if (lastToggleTime == null ||
                                now.difference(lastToggleTime!).inMilliseconds > 500) {
                              setState(() {
                                showLast3Months = true;
                                lastToggleTime = now;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            backgroundColor: showLast3Months
                                ? Colors.black
                                : Colors.grey.shade200,
                            foregroundColor: showLast3Months
                                ? Colors.white
                                : Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Last 3 Months',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  showLast3Months
                      ? BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            if (state is AuthAuthenticated &&
                                state.user.customerId != null) {
                              // Usar el TrafficBloc global que ya está disponible
                              return DataUsageBarChart(
                                customerId: state.user.customerId.toString(),
                              );
                            }
                            return const Center(
                              child: Text(
                                'Could not get customer ID',
                              ),
                            );
                          },
                        )
                      : const DataUsageDonutChart(),
                ],
              ),
            ),
            // Card de dispositivos conectados
            const ConnectedDevicesCard(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
