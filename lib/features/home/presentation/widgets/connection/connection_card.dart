import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uwifiapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:uwifiapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:uwifiapp/injection_container.dart' as di;

import '../../../../../core/utils/responsive_font_sizes_screen.dart';
import '../../bloc/connection_bloc.dart';
import '../../bloc/connection_event.dart';
import '../../bloc/connection_state.dart' as connection_state;
import 'connection_details_page.dart';

class ConnectionCard extends StatefulWidget {
  const ConnectionCard({super.key});

  @override
  State<ConnectionCard> createState() => _ConnectionCardState();
}

class _ConnectionCardState extends State<ConnectionCard> {
  @override
  void initState() {
    super.initState();
    _loadConnectionInfo();
  }

  void _loadConnectionInfo() {
    // Get customer ID from authentication state
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated && authState.user.customerId != null) {
      // GetConnectionInfoEvent expects a non-null int
      final customerId = authState.user.customerId!;
      context.read<ConnectionBloc>().add(GetConnectionInfoEvent(customerId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 100,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Row(
        children: [
          // Gateway image container
          Container(
            width: 120,
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFFE8EAF6),
              borderRadius: BorderRadius.circular(100),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.asset(
                'assets/images/homeimage/realGateway.png',
                fit: BoxFit.cover,
                width: 120,
                height: 180,
              ),
            ),
          ),

          const SizedBox(width: 20),

          // Right side content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Connection status and WiFi name
                BlocBuilder<ConnectionBloc, connection_state.ConnectionState>(
                  builder: (context, state) {
                    // Determine connection status and WiFi name
                    String connectionStatus = 'Loading...';
                    String wifiName = 'Searching...';
                    Color statusColor = Colors.grey;

                    if (state is connection_state.ConnectionLoaded) {
                      connectionStatus = state.gatewayInfo.connectionStatus;
                      wifiName = state.gatewayInfo.wifiName;
                      statusColor = connectionStatus == 'Connected'
                          ? const Color(0xFF4CAF50)
                          : Colors.red;
                    } else if (state is connection_state.ConnectionLoading &&
                        state.previousInfo != null) {
                      connectionStatus = state.previousInfo!.connectionStatus;
                      wifiName = state.previousInfo!.wifiName;
                      statusColor = connectionStatus == 'Connected'
                          ? const Color(0xFF4CAF50)
                          : Colors.red;
                    } else if (state is connection_state.ConnectionError) {
                      connectionStatus = 'Error';
                      wifiName = 'No connection';
                      statusColor = Colors.red;
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Connection status
                        Text(
                          connectionStatus,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: responsiveFontSizesScreen.labelLarge(
                              context,
                            ),
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // WiFi name
                        Text(
                          wifiName,
                          style: TextStyle(
                            fontSize: responsiveFontSizesScreen.titleLarge(
                              context,
                            ),
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Details button
                ElevatedButton(
                  onPressed: () {
                    // Get customer ID from authentication state
                    final authState = context.read<AuthBloc>().state;
                    if (authState is AuthAuthenticated &&
                        authState.user.customerId != null) {
                      final customerId = authState.user.customerId!;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => BlocProvider<ConnectionBloc>(
                            create: (_) {
                              final bloc = di.getIt<ConnectionBloc>();
                              bloc.add(GetConnectionInfoEvent(customerId));
                              return bloc;
                            },
                            child: const ConnectionDetailsPage(),
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade300,
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Connection Details'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
