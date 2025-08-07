import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../customer/presentation/bloc/customer_details_bloc.dart';
import '../widgets/settings/settings_modal.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Variables para almacenar la información de la aplicación
  String appName = '';
  String appVersion = '';
  String appBuild = '';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  // Función para cargar la información de la aplicación
  Future<void> _loadAppInfo() async {
    try {
      final PackageInfo info = await PackageInfo.fromPlatform();
      setState(() {
        appName = info.appName;
        appVersion = info.version;
        appBuild = '27';
      });
    } catch (e) {
      // En caso de error, usar valores predeterminados
      setState(() {
        appName = 'U-wifi';
        appVersion = '1.0.0';
        appBuild = '27';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        // Obtener el email del usuario autenticado
        final String email = authState is AuthAuthenticated
            ? authState.user.email
            : 'frank.befera@u-wifi.com';

        // Si el usuario está autenticado, disparar el evento para obtener los detalles del cliente
        if (authState is AuthAuthenticated &&
            authState.user.customerId != null) {
          // Verificar si ya tenemos los detalles del cliente
          final customerState = context.watch<CustomerDetailsBloc>().state;
          if (customerState is! CustomerDetailsLoaded &&
              customerState is! CustomerDetailsLoading) {
            AppLogger.navInfo(
              'Solicitando detalles del cliente desde ProfilePage',
            );
            context.read<CustomerDetailsBloc>().add(
              FetchCustomerDetails(authState.user.customerId!),
            );
          }
        }

        // Usar BlocBuilder anidado para obtener los detalles del cliente
        return BlocBuilder<CustomerDetailsBloc, CustomerDetailsState>(
          builder: (context, customerState) {
            // Determinar el nombre a mostrar
            String name;
            if (customerState is CustomerDetailsLoaded) {
              name = customerState.customerDetails.fullName;
              AppLogger.navInfo('Usando nombre del cliente: $name');
            } else if (authState is AuthAuthenticated) {
              name = authState.user.name ?? 'Usuario';
              AppLogger.navInfo('Usando nombre del usuario autenticado: $name');
            } else {
              name = 'Usuario';
              AppLogger.navInfo('Usando nombre predeterminado: $name');
            }

            // Calcular las iniciales
            final String initials = name.isNotEmpty
                ? name
                      .trim()
                      .split(' ')
                      .map((e) => e.isNotEmpty ? e[0] : '')
                      .take(2)
                      .join()
                      .toUpperCase()
                : 'U';
            return Scaffold(
              backgroundColor: Colors.white,
              body: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.grey.shade400,
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: Colors.grey.shade200,
                              child: Text(
                                initials,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    email,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Account',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _ProfileOption(
                                icon: Icons.account_balance_wallet_outlined,
                                label: 'My Wallet',
                                onTap: () {
                                  Navigator.of(
                                    context,
                                  ).pushNamed(AppRouter.wallet);
                                },
                              ),
                              const SizedBox(height: 12),
                              _ProfileOption(
                                icon: Icons.storefront_outlined,
                                label: 'U-wifi Store',
                                onTap: () {
                                  Navigator.of(
                                    context,
                                  ).pushNamed(AppRouter.uwifiStore);
                                },
                              ),
                              const SizedBox(height: 28),
                              const Text(
                                'App Settings',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _ProfileOption(
                                icon: Icons.wifi_tethering,
                                label: 'My U-Wifi Plan',
                                onTap: () {
                                  Navigator.of(
                                    context,
                                  ).pushNamed(AppRouter.myUwifiPlan);
                                },
                              ),
                              const SizedBox(height: 12),
                              _ProfileOption(
                                icon: Icons.settings,
                                label: 'Settings',
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) => const SettingsModal(),
                                  );
                                },
                              ),
                              const SizedBox(height: 36),
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      '© 2025 $appName. All rights reserved. | Version $appVersion',
                                      style: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Test Version: $appVersion ($appBuild)',
                                      style: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              Center(
                                child: SizedBox(
                                  width: 180,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: const BorderSide(color: Colors.red),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                    onPressed: () {
                                      _showLogoutDialog(context);
                                    },
                                    child: const Text(
                                      'Log Out',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(LogoutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ProfileOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300, width: 1.2),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black54, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
