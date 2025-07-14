import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/data_usage_bloc.dart';
import '../../bloc/data_usage_event.dart';
import '../../bloc/data_usage_state.dart';

class DataUsageDonutChart extends StatelessWidget {
  const DataUsageDonutChart({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataUsageBloc, DataUsageState>(
      builder: (context, state) {
        if (state is DataUsageLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is DataUsageLoaded) {
          // Convertir bytes a GB para mostrar
          final downloadGB = state.dataUsage.monthlyRx / (1024 * 1024 * 1024);
          final uploadGB = state.dataUsage.monthlyTx / (1024 * 1024 * 1024);
          final totalGB = state.dataUsage.monthlyTotal / (1024 * 1024 * 1024);
          
          // Calcular porcentaje de descarga vs subida
          final downloadPercentage = state.dataUsage.monthlyRx / state.dataUsage.monthlyTotal;
          
          return Column(
            children: [
              Text(
                'Total Used: ${totalGB.toStringAsFixed(2)} GB',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Download: ${downloadGB.toStringAsFixed(2)} GB', 
                style: const TextStyle(color: Colors.green),
              ),
              Text(
                'Upload: ${uploadGB.toStringAsFixed(2)} GB', 
                style: const TextStyle(color: Colors.purple),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                width: 120,
                child: Stack(
                  children: [
                    // Donut chart
                    CircularProgressIndicator(
                      value: downloadPercentage,
                      strokeWidth: 16,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                      backgroundColor: Colors.purple,
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${(downloadPercentage * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const Text('Download', style: TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        } else if (state is DataUsageError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('Error: ${state.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Intentar cargar los datos nuevamente
                    context.read<DataUsageBloc>().add(
                          const GetDataUsageEvent(customerId: 'customer_id'),
                        );
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        } else {
          // Estado inicial o desconocido
          return const Center(
            child: Text('No hay datos disponibles'),
          );
        }
      },
    );
  }
}
