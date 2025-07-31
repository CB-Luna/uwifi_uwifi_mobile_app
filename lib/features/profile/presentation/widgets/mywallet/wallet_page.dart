import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/app_logger.dart';
import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../auth/presentation/bloc/auth_state.dart';
import '../../../domain/entities/credit_card.dart';
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
    // Cargar usuarios afiliados, tarjetas y puntos después de que el widget se haya construido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAffiliatedUsers();
      _loadCreditCards();
      _loadCustomerPoints();
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

  void _loadCustomerPoints() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final user = authState.user;

      // Verificar si el usuario tiene customerId
      if (user.customerId != null) {
        final customerAfiliateId = user.customerAfiliateId?.toString();

        AppLogger.navInfo(
          'Cargando puntos del cliente para customerId: ${user.customerId}${customerAfiliateId != null ? ', customerAfiliateId: $customerAfiliateId' : ''}',
        );

        context.read<WalletBloc>().add(
          GetCustomerPointsEvent(
            customerId: user.customerId.toString(),
            customerAfiliateId: customerAfiliateId,
          ),
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

  // Método para establecer una tarjeta como predeterminada
  void _setDefaultCard(CreditCard card) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final user = authState.user;
      if (user.customerId != null) {
        // Mostrar un diálogo de confirmación
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Set as Default'),
            content: Text(
              'Do you want to set ${card.cardHolder}\'s card ending in ${card.last4Digits} as your default payment method?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Cerrar el diálogo
                  Navigator.of(context).pop();

                  // Enviar el evento para establecer la tarjeta como predeterminada
                  context.read<PaymentBloc>().add(
                    SetDefaultCardEvent(
                      customerId: user.customerId.toString(),
                      cardId: card.id.toString(),
                    ),
                  );

                  // Mostrar un mensaje de éxito
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Setting card as default...'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Confirm'),
              ),
            ],
          ),
        );
      }
    }
  }

  // Método para eliminar una tarjeta
  void _deleteCard(CreditCard card) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final user = authState.user;
      if (user.customerId != null) {
        // Mostrar un diálogo de confirmación
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Card'),
            content: Text(
              'Are you sure you want to delete the card ending in ${card.last4Digits}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Cerrar el diálogo
                  Navigator.of(context).pop();

                  // Enviar el evento para eliminar la tarjeta
                  context.read<PaymentBloc>().add(
                    DeleteCreditCardEvent(
                      customerId: user.customerId.toString(),
                      cardId: card.id.toString(),
                    ),
                  );

                  // Mostrar un mensaje de éxito
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Deleting card...'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            BlocBuilder<WalletBloc, WalletState>(
              builder: (context, state) {
                if (state is WalletLoaded && state.customerPoints != null) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${state.customerPoints!.totalPointsEarned}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Text('Points', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  );
                } else if (state is WalletLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (state is WalletError) {
                  return Center(
                    child: Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else {
                  return const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '0',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 6),
                      Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Text('Points', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  );
                }
              },
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
            BlocBuilder<WalletBloc, WalletState>(
              builder: (context, state) {
                // Calcular el progreso basado en los puntos del cliente
                double progress = 0.0;
                int totalPoints = 0;
                bool isFirstActive = false;
                bool isSecondActive = false;
                bool isThirdActive = false;

                if (state is WalletLoaded && state.customerPoints != null) {
                  totalPoints = state.customerPoints!.totalPointsEarned;

                  // Determinar qué círculos están activos basado en los puntos
                  isFirstActive = totalPoints >= 1000;
                  isSecondActive = totalPoints >= 2000;
                  isThirdActive = totalPoints >= 4000;

                  // Calcular el progreso para la línea
                  if (totalPoints >= 4000) {
                    progress = 1.0; // 100% de progreso
                  } else if (totalPoints >= 2000) {
                    // Entre $20 y $38 (2000 a 4000 puntos)
                    progress = 0.5 + ((totalPoints - 2000) / 2000) * 0.5;
                  } else if (totalPoints >= 1000) {
                    // Entre $10 y $20 (1000 a 2000 puntos)
                    progress = 0.25 + ((totalPoints - 1000) / 1000) * 0.25;
                  } else {
                    // Entre $0 y $10 (0 a 1000 puntos)
                    progress = (totalPoints / 1000) * 0.25;
                  }
                }

                return Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Línea de conexión (background)
                      Positioned(
                        left: 30,
                        right: 30,
                        child: Container(
                          height: 4,
                          color: Colors.grey.shade300,
                        ),
                      ),
                      // Línea de progreso (foreground)
                      Positioned(
                        left: 30,
                        width:
                            (MediaQuery.of(context).size.width - 76) * progress,
                        child: Container(height: 4, color: Colors.teal),
                      ),
                      // Círculos de puntos
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildPointCircle(
                            '\$10',
                            isFirstActive,
                            isFirstActive ? Colors.teal : Colors.grey,
                          ),
                          _buildPointCircle(
                            '\$20',
                            isSecondActive,
                            isSecondActive ? Colors.teal : Colors.grey,
                          ),
                          _buildPointCircle(
                            '\$38',
                            isThirdActive,
                            isThirdActive ? Colors.teal : Colors.grey,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
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
                    'Affiliate',
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
                // Mostrar indicador de carga solo si no hay datos previos
                if (state is WalletLoading && state.affiliatedUsers == null) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                // Obtener usuarios afiliados del estado actual
                final users = state is WalletLoaded
                    ? state.affiliatedUsers
                    : state is WalletLoading && state.affiliatedUsers != null
                    ? state.affiliatedUsers!
                    : [];

                if (users.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('No affiliated users found'),
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
              },
            ),
            const SizedBox(height: 24),
            BlocBuilder<PaymentBloc, PaymentState>(
              builder: (context, paymentState) {
                // Obtener el número de tarjetas
                int cardCount = 0;
                if (paymentState is PaymentLoaded) {
                  cardCount = paymentState.creditCards.length;
                }
                
                return Row(
                  children: [
                    Text(
                      'Payment Methods${cardCount > 0 ? ' ($cardCount)' : ''}',
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
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
                );
              },
            ),
            const SizedBox(height: 24),
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
                          'You have no cards registered',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    );
                  }
                  return SizedBox(
                    height: 250,
                    child: CreditCardSwiper(
                      cards: cards,
                      onSetDefault: _setDefaultCard,
                      onDelete: _deleteCard,
                    ),
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
