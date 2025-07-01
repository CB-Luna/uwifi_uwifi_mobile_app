import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/invite_bloc.dart';
import '../bloc/invite_event.dart';
import '../bloc/invite_state.dart';
import '../widgets/invite_header_widget.dart';
import '../widgets/referral_link_widget.dart';
import '../widgets/how_it_works_widget.dart';

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
    // Cargar información del referido al inicializar
    context.read<InviteBloc>().add(const LoadUserReferralEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
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
              return const Center(
                child: CircularProgressIndicator(),
              );
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
                        context.read<InviteBloc>().add(const LoadUserReferralEvent());
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            // Estado inicial
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
