import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_logger.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../customer/presentation/bloc/customer_details_bloc.dart';
import '../bloc/invite_bloc.dart';
import '../bloc/invite_event.dart';
import '../bloc/invite_state.dart';
import '../widgets/how_it_works_widget.dart';
import '../widgets/invite_header_widget.dart';
import '../widgets/referral_link_widget.dart';

/// Página principal de invitaciones
class InvitePage extends StatefulWidget {
  const InvitePage({super.key});

  @override
  State<InvitePage> createState() => _InvitePageState();
}

class _InvitePageState extends State<InvitePage> {
  @override
  void initState() {
    super.initState();

    // Primero cargamos los detalles del cliente para asegurar que tengamos el sharedLinkId
    _loadCustomerDetails();
  }

  void _loadCustomerDetails() {
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthAuthenticated && authState.user.customerId != null) {
      final customerIdInt = authState.user.customerId!;

      if (customerIdInt > 0) {
        AppLogger.navInfo(
          'InvitePage: Cargando detalles del cliente ID: $customerIdInt',
        );
        // Cargamos los detalles del cliente
        context.read<CustomerDetailsBloc>().add(
          FetchCustomerDetails(customerIdInt),
        );
      } else {
        AppLogger.navError(
          'InvitePage: No se pudo obtener un customerId válido',
        );
        // Si no hay un customerId válido, cargamos los datos de referido directamente
        context.read<InviteBloc>().add(const LoadUserReferralEvent());
      }
    } else {
      AppLogger.navError('InvitePage: Usuario no autenticado o sin customerId');
      // Si no hay usuario autenticado, cargamos los datos de referido directamente
      context.read<InviteBloc>().add(const LoadUserReferralEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        // Primero escuchamos los cambios en CustomerDetailsBloc
        child: BlocListener<CustomerDetailsBloc, CustomerDetailsState>(
          listener: (context, customerState) {
            if (customerState is CustomerDetailsLoaded) {
              final customerDetails = customerState.customerDetails;
              AppLogger.navInfo(
                'InvitePage: CustomerDetails cargado con sharedLinkId: ${customerDetails.sharedLinkId}',
              );
              // Una vez que tenemos los detalles del cliente, cargamos los datos de referido
              // pasando explícitamente el CustomerDetails al evento
              context.read<InviteBloc>().add(
                LoadUserReferralEvent(customerDetails: customerDetails),
              );
            } else if (customerState is CustomerDetailsError) {
              AppLogger.navError(
                'InvitePage: Error al cargar CustomerDetails: ${customerState.message}',
              );
              // Si hay error, cargamos los datos de referido sin CustomerDetails
              context.read<InviteBloc>().add(const LoadUserReferralEvent());
            }
          },
          // Luego mostramos la UI basada en InviteBloc
          child: BlocConsumer<InviteBloc, InviteState>(
            listener: (context, state) {
              if (state is InviteShared) {
                _showSuccessSnackBar('Enlace compartido exitosamente');
              } else if (state is InviteLinkCopied) {
                _showSuccessSnackBar('Enlace copiado al portapapeles');
              } else if (state is InviteError) {
                _showErrorSnackBar(state.message);
              }
            },
            builder: (context, state) {
              if (state is InviteLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is InviteLoaded) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header con gradiente
                      const InviteHeaderWidget(),
                      const SizedBox(height: 24),

                      // Widget del enlace de referido
                      ReferralLinkWidget(
                        referralLink: state.referral.referralLink,
                        referralCode: state.referral.referralCode,
                      ),
                      const SizedBox(height: 32),

                      // Sección "Cómo funciona"
                      const HowItWorksWidget(),
                    ],
                  ),
                );
              } else if (state is InviteError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error al cargar invitaciones',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          // Intentamos obtener los detalles del cliente actuales
                          final customerState = context
                              .read<CustomerDetailsBloc>()
                              .state;
                          if (customerState is CustomerDetailsLoaded) {
                            // Si tenemos los detalles, los pasamos al evento
                            context.read<InviteBloc>().add(
                              LoadUserReferralEvent(
                                customerDetails: customerState.customerDetails,
                              ),
                            );
                          } else {
                            // Si no tenemos los detalles, cargamos sin ellos
                            context.read<InviteBloc>().add(
                              const LoadUserReferralEvent(),
                            );
                          }
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              }

              // Estado inicial
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
