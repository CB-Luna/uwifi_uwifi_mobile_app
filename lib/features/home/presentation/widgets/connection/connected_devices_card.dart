import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

import '../../../domain/entities/gateway_info.dart';
import '../../bloc/connection_bloc.dart';
import '../../bloc/connection_state.dart' as connection_state;

class ConnectedDevicesCard extends StatefulWidget {
  const ConnectedDevicesCard({super.key});

  @override
  State<ConnectedDevicesCard> createState() => _ConnectedDevicesCardState();
}

class _ConnectedDevicesCardState extends State<ConnectedDevicesCard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: BlocBuilder<ConnectionBloc, connection_state.ConnectionState>(
        builder: (context, state) {
          if (state is connection_state.ConnectionLoading) {
            return const _LoadingView();
          } else if (state is connection_state.ConnectionLoaded) {
            return _buildContent(state.gatewayInfo);
          } else if (state is connection_state.ConnectionError) {
            return _ErrorView(message: state.message);
          }
          return const _EmptyView();
        },
      ),
    );
  }

  Widget _buildContent(GatewayInfo gatewayInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.devices, size: 18),
            const SizedBox(width: 6),
            const Text(
              'Devices',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(width: 6),
            Text(
              'Connected Devices (${gatewayInfo.devices24G.length + gatewayInfo.devices5G.length})',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: '2.4 GHz'),
            Tab(text: '5 GHz'),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 150, // Altura reducida para el contenido de las pestañas
          child: TabBarView(
            controller: _tabController,
            children: [
              // Pestaña 2.4 GHz
              _DevicesTabContent(
                devices: gatewayInfo.devices24G,
                networkName: gatewayInfo.wifi24GName,
              ),
              // Pestaña 5 GHz
              _DevicesTabContent(
                devices: gatewayInfo.devices5G,
                networkName: gatewayInfo.wifi5GName,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DevicesTabContent extends StatelessWidget {
  final List<ConnectedDevice> devices;
  final String networkName;

  const _DevicesTabContent({required this.devices, required this.networkName});

  @override
  Widget build(BuildContext context) {
    if (devices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 60,
              width: 60,
              child: Lottie.asset(
                'assets/animations/lotties/no_connected_devices.json',
                repeat: true,
                animate: true,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'No connected devices to $networkName',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: devices.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final device = devices[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              const Icon(Icons.devices, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      device.name ?? 'Unknown Device',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'MAC: ${device.macAddress ?? 'N/A'} | IP: ${device.ipAddress ?? 'N/A'}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.devices, size: 18),
            SizedBox(width: 6),
            Text('Devices', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
        SizedBox(height: 12),
        Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))),
        SizedBox(height: 12),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.devices, size: 18),
            SizedBox(width: 6),
            Text('Devices', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Error: $message',
            style: const TextStyle(color: Colors.red, fontSize: 13),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.devices, size: 18),
            SizedBox(width: 6),
            Text('Devices', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
        SizedBox(height: 12),
        Center(
          child: Text(
            'No available information',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
        SizedBox(height: 12),
      ],
    );
  }
}
