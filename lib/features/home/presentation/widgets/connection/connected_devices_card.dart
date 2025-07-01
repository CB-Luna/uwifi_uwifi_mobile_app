import 'package:flutter/material.dart';

class ConnectedDevicesCard extends StatelessWidget {
  const ConnectedDevicesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.devices, size: 20),
              SizedBox(width: 8),
              Text('Devices', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(width: 8),
              Text('Connected Devices', style: TextStyle(color: Colors.grey)),
            ],
          ),
          SizedBox(height: 12),
          // Lista mock de dispositivos
          Text('--'),
          Text('--'),
        ],
      ),
    );
  }
}
