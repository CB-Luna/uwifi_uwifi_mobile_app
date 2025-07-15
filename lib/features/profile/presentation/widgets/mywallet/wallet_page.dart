import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/app_logger.dart';
import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../auth/presentation/bloc/auth_state.dart';
import '../../bloc/payment_bloc.dart';
import '../../bloc/payment_event.dart';
import '../../bloc/payment_state.dart';
import '../../bloc/wallet_bloc.dart';
import '../../bloc/wallet_event.dart';
import '../../bloc/wallet_state.dart';
import 'credit_card_swiper.dart';
import 'user_circle.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  // Método para construir los círculos de puntos
  Widget _buildPointCircle(String value, bool isActive, Color color) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? color : Colors.grey.shade600,
        border: Border.all(
          color: isActive ? Colors.teal.shade200 : Colors.grey.shade400,
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: isActive
                ? Colors.teal.withValues(alpha: 0.3)
                : Colors.transparent,
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Cargar usuarios afiliados y tarjetas después de que el widget se haya construido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAffiliatedUsers();
      _loadCreditCards();
    });
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

  void _loadCreditCards() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final user = authState.user;

      // Verificar si el usuario tiene customerId
      if (user.customerId != null) {
        AppLogger.navInfo(
          'Cargando tarjetas para customerId: ${user.customerId}',
        );
        context.read<PaymentBloc>().add(
          GetCreditCardsEvent(user.customerId.toString()),
        );
      } else {
        AppLogger.navError('Error: El usuario no tiene customerId asignado');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'My Wallet',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Free U Points',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '30',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 6),
                Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Text('Points', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Row(
              children: [
                Text(
                  'My Accumulated U-Points',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                ),
                SizedBox(width: 6),
                Tooltip(
                  message: 'Total U-Points accumulated',
                  child: Icon(
                    Icons.info_outline,
                    size: 18,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Línea de conexión (background)
                  Positioned(
                    left: 30,
                    right: 30,
                    child: Container(height: 4, color: Colors.grey.shade300),
                  ),
                  // Línea de progreso (foreground)
                  Positioned(
                    left: 30,
                    width:
                        MediaQuery.of(context).size.width * 0.3 -
                        60, // 0.3 es el valor de progreso
                    child: Container(height: 4, color: Colors.teal),
                  ),
                  // Círculos de puntos
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPointCircle('\$10', true, Colors.teal),
                      _buildPointCircle('\$20', false, Colors.grey),
                      _buildPointCircle('\$38', false, Colors.grey),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            const SizedBox(height: 18),
            Row(
              children: [
                const Text(
                  'Me and my affiliated users',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                ),
                const SizedBox(width: 6),
                const Tooltip(
                  message: 'Users affiliated to your account',
                  child: Icon(
                    Icons.info_outline,
                    size: 18,
                    color: Colors.black45,
                  ),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/adduser');
                  },
                  icon: const Icon(Icons.add, color: Colors.green),
                  label: const Text(
                    'Add User',
                    style: TextStyle(color: Colors.green),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.green),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            BlocBuilder<WalletBloc, WalletState>(
              builder: (context, state) {
                if (state is WalletLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (state is WalletLoaded) {
                  final users = state.affiliatedUsers;
                  if (users.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('No hay usuarios afiliados'),
                    );
                  }
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: users
                          .map((user) => UserCircle.fromAffiliatedUser(user))
                          .toList(),
                    ),
                  );
                } else if (state is WalletError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else {
                  return const Row(children: [UserCircle(initials: '...')]);
                }
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text(
                  'Payment Methods',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/addcard');
                  },
                  icon: const Icon(Icons.add, color: Colors.green),
                  label: const Text(
                    'Add Card',
                    style: TextStyle(color: Colors.green),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.green),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            BlocBuilder<PaymentBloc, PaymentState>(
              builder: (context, state) {
                if (state is PaymentLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (state is PaymentLoaded) {
                  final cards = state.creditCards;
                  if (cards.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: Text(
                          'No tienes tarjetas registradas',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    );
                  }
                  return SizedBox(
                    height: 380,
                    child: CreditCardSwiper(cards: cards),
                  );
                } else if (state is PaymentError) {
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
                            onPressed: _loadCreditCards,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/images/profile/CreditCardUI.png',
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// El widget UserCircle se ha movido a un archivo separado
