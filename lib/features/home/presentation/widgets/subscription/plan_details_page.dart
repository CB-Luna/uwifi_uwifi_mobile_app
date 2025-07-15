import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../core/utils/app_logger.dart';
import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../auth/presentation/bloc/auth_state.dart';
import '../../../../profile/presentation/bloc/wallet_bloc.dart';
import '../../../../profile/presentation/bloc/wallet_event.dart';
import '../../../../profile/presentation/bloc/wallet_state.dart';
import '../../../domain/entities/transaction.dart';
import '../../bloc/billing_bloc.dart';
import '../../bloc/billing_event.dart';
import '../../bloc/billing_state.dart';
import '../../bloc/service_bloc.dart';
import '../../bloc/service_event.dart';
import '../../bloc/service_state.dart';
import '../../bloc/transaction_bloc.dart';
import '../../bloc/transaction_event.dart';
import '../../bloc/transaction_state.dart';

class PlanDetailsPage extends StatefulWidget {
  const PlanDetailsPage({super.key});

  @override
  State<PlanDetailsPage> createState() => _PlanDetailsPageState();
}

class _PlanDetailsPageState extends State<PlanDetailsPage> {
  // Estado para controlar el orden de las transacciones
  bool _newestFirst = true;

  // Variable para controlar la expansión de la sección de usuarios
  bool _isUserGroupExpanded = false;

  @override
  void initState() {
    super.initState();
    // Cargar datos después de que el widget se haya construido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTransactionHistory();
      _loadAffiliatedUsers();
      _loadBillingPeriod();
      _loadCustomerActiveServices();
    });
  }

  void _loadTransactionHistory() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final user = authState.user;

      // Verificar si el usuario tiene customerId
      if (user.customerId != null) {
        AppLogger.navInfo(
          'Cargando historial de transacciones para customerId: ${user.customerId}',
        );
        context.read<TransactionBloc>().add(
          GetTransactionHistoryEvent(user.customerId.toString()),
        );
      } else {
        AppLogger.navError('Error: El usuario no tiene customerId asignado');
      }
    }
  }

  void _loadBillingPeriod() {
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        final user = authState.user;

        // Verificar si el usuario tiene customerId
        if (user.customerId != null) {
          AppLogger.navInfo(
            'Cargando período de facturación para customerId: ${user.customerId}',
          );

          // Intentar acceder a BillingBloc
          context.read<BillingBloc>().add(
            GetBillingPeriodEvent(customerId: user.customerId.toString()),
          );
        } else {
          AppLogger.navError('Error: El usuario no tiene customerId asignado');
        }
      }
    } catch (e) {
      AppLogger.navError('Error al cargar período de facturación: $e');
    }
  }

  void _loadCustomerActiveServices() {
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        final user = authState.user;

        // Verificar si el usuario tiene customerId
        if (user.customerId != null) {
          AppLogger.navInfo(
            'Cargando servicios activos para customerId: ${user.customerId}',
          );

          // Intentar acceder a ServiceBloc
          context.read<ServiceBloc>().add(
            GetCustomerActiveServicesEvent(
              customerId: user.customerId.toString(),
            ),
          );
        } else {
          AppLogger.navError('Error: El usuario no tiene customerId asignado');
        }
      }
    } catch (e) {
      AppLogger.navError('Error al cargar servicios activos: $e');
    }
  }

  void _loadAffiliatedUsers() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final user = authState.user;

      // Verificar si el usuario tiene customerId
      if (user.customerId != null) {
        AppLogger.navInfo(
          'Cargando usuarios afiliados para customerId: ${user.customerId}',
        );
        context.read<WalletBloc>().add(
          GetAffiliatedUsersEvent(customerId: user.customerId.toString()),
        );
      } else {
        AppLogger.navError('Error: El usuario no tiene customerId asignado');
      }
    }
  }

  // Método para mostrar las opciones de ordenamiento
  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      // Ajustar la altura del BottomSheet para que aparezca más arriba
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.4,
      ),
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Sort Transactions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.arrow_downward),
              title: const Text('Newest first'),
              trailing: _newestFirst
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                setState(() {
                  _newestFirst = true;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.arrow_upward),
              title: const Text('Oldest first'),
              trailing: !_newestFirst
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                setState(() {
                  _newestFirst = false;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'My Plan Details',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta de plan activo
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/homeimage/launcher.png',
                    height: 48,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        try {
                          return BlocBuilder<ServiceBloc, ServiceState>(
                            builder: (context, serviceState) {
                              try {
                                return BlocBuilder<BillingBloc, BillingState>(
                                  builder: (context, billingState) {
                                    // Obtener el nombre y tipo del servicio
                                    String serviceName = 'U-Wifi Internet';
                                    String serviceType = 'Recurring Charge';

                                    if (serviceState is ServiceLoaded &&
                                        serviceState.services.isNotEmpty) {
                                      final service =
                                          serviceState.services.first;
                                      serviceName = service.name;
                                      serviceType = service.type;
                                    }

                                    // Obtener la fecha de vencimiento
                                    String dueDate = 'Due date: --';

                                    if (billingState is BillingLoaded) {
                                      final endDate =
                                          billingState.billingPeriod.dueDate;
                                      final formattedDate = DateFormat(
                                        'MMM dd',
                                      ).format(DateTime.parse(endDate));
                                      dueDate = 'Due date: $formattedDate';
                                    }

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          serviceName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          serviceType,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          dueDate,
                                          style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } catch (e) {
                                AppLogger.navError('Error en BillingBloc: $e');
                                return const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'U-Wifi Internet',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      'Recurring Charge',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Due date: --',
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                );
                              }
                            },
                          );
                        } catch (e) {
                          AppLogger.navError('Error en ServiceBloc: $e');
                          return const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'U-Wifi Internet',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Recurring Charge',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Due date: --',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Active',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            // Transaction History
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[600]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.list_alt, color: Colors.black54),
                      const SizedBox(width: 6),
                      const Text(
                        'Transaction History',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          _showSortOptions(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.sort,
                                size: 18,
                                color: Colors.black45,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _newestFirst ? 'newest' : 'oldest',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                size: 18,
                                color: Colors.black45,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Lista de transacciones (scroll interno, máximo 5 visibles)
                  BlocBuilder<TransactionBloc, TransactionState>(
                    builder: (context, state) {
                      if (state is TransactionLoading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      } else if (state is TransactionLoaded) {
                        final transactions = state.transactions;
                        if (transactions.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(
                              child: Text(
                                'No hay transacciones disponibles',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          );
                        }
                        // Ordenar las transacciones según la preferencia del usuario
                        final sortedTransactions = List<Transaction>.from(
                          transactions,
                        );
                        if (_newestFirst) {
                          sortedTransactions.sort(
                            (a, b) => b.createdAt.compareTo(a.createdAt),
                          );
                        } else {
                          sortedTransactions.sort(
                            (a, b) => a.createdAt.compareTo(b.createdAt),
                          );
                        }

                        return ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: 320,
                          ), // 5 * aprox 64px
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                            itemCount: sortedTransactions.length,
                            itemBuilder: (context, i) =>
                                _transactionItem(sortedTransactions[i]),
                          ),
                        );
                      } else if (state is TransactionError) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 48,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Error: ${state.message}',
                                  style: const TextStyle(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: _loadTransactionHistory,
                                  child: const Text('Reintentar'),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // My user group
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isUserGroupExpanded = !_isUserGroupExpanded;
                      });
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.people, size: 20),
                        const SizedBox(width: 6),
                        const Text(
                          'My user group',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          _isUserGroupExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                  if (_isUserGroupExpanded)
                    BlocBuilder<WalletBloc, WalletState>(
                      builder: (context, state) {
                        // Mostrar indicador de carga solo si no hay datos previos
                        if (state is WalletLoading &&
                            state.affiliatedUsers == null) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        // Obtener usuarios afiliados del estado actual
                        final users = state is WalletLoaded
                            ? state.affiliatedUsers
                            : state is WalletLoading &&
                                  state.affiliatedUsers != null
                            ? state.affiliatedUsers!
                            : [];

                        // Mostrar mensaje si no hay usuarios
                        if (users.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(
                              child: Text(
                                'No hay usuarios afiliados',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          );
                        }

                        // Mostrar la lista de usuarios
                        return Column(
                          children: [
                            // Mostrar los usuarios afiliados
                            ...users.map(
                              (user) => _userItem(
                                user.customerName,
                                user.initials,
                                isAffiliate: user.isAffiliate,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _transactionItem(Transaction transaction) {
    // Determinar el icono y color según el tipo de transacción
    IconData icon;
    Color iconColor;

    if (transaction.transactionType.toLowerCase() == 'payment') {
      icon = Icons.payment;
      iconColor = Colors.blue;
    } else if (transaction.transactionType.toLowerCase() ==
        'recurring charge') {
      icon = Icons.attach_money;
      iconColor = Colors.green;
    } else {
      icon = Icons.receipt;
      iconColor = Colors.orange;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: iconColor.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.transactionType,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'Transaction ID: ${transaction.transactionId}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  transaction.formattedDate,
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '\$${transaction.amount.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _userItem(String name, String initials, {bool isAffiliate = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[400],
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
          if (!isAffiliate)
            const Icon(Icons.star, color: Colors.amber, size: 20),
        ],
      ),
    );
  }
}
