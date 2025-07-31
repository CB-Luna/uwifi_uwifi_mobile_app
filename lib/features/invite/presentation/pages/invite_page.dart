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

/// Main invitations page
class InvitePage extends StatefulWidget {
  const InvitePage({super.key});

  @override
  State<InvitePage> createState() => _InvitePageState();
}

class _InvitePageState extends State<InvitePage> {
  @override
  void initState() {
    super.initState();

    // First load customer details to ensure we have the sharedLinkId
    _loadCustomerDetails();
  }

  void _loadCustomerDetails() {
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthAuthenticated && authState.user.customerId != null) {
      final customerIdInt = authState.user.customerId!;

      if (customerIdInt > 0) {
        AppLogger.navInfo(
          'InvitePage: Loading customer details ID: $customerIdInt',
        );
        // Load customer details
        context.read<CustomerDetailsBloc>().add(
          FetchCustomerDetails(customerIdInt),
        );
      } else {
        AppLogger.navError('InvitePage: Could not get a valid customerId');
        // If there is no valid customerId, load referral data directly
        context.read<InviteBloc>().add(const LoadUserReferralEvent());
      }
    } else {
      AppLogger.navError(
        'InvitePage: User not authenticated or without customerId',
      );
      // If there is no authenticated user, load referral data directly
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
                'InvitePage: CustomerDetails loaded with sharedLinkId: ${customerDetails.sharedLinkId}',
              );
              // Once we have customer details, load referral data
              // explicitly passing CustomerDetails to the event
              context.read<InviteBloc>().add(
                LoadUserReferralEvent(customerDetails: customerDetails),
              );
            } else if (customerState is CustomerDetailsError) {
              AppLogger.navError(
                'InvitePage: Error loading CustomerDetails: ${customerState.message}',
              );
              // If there's an error, load referral data without CustomerDetails
              context.read<InviteBloc>().add(const LoadUserReferralEvent());
            }
          },
          // Luego mostramos la UI basada en InviteBloc
          child: BlocConsumer<InviteBloc, InviteState>(
            listener: (context, state) {
              if (state is InviteShared) {
                _showSuccessSnackBar('Link shared successfully');
              } else if (state is InviteLinkCopied) {
                _showSuccessSnackBar('Link copied to clipboard');
              } else if (state is InviteError) {
                _showErrorSnackBar(state.message);
              }
            },
            builder: (context, state) {
              if (state is InviteLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is InviteLoaded) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with gradient - más compacto
                      const InviteHeaderWidget(),
                      const SizedBox(height: 16),

                      // Referral link widget
                      ReferralLinkWidget(
                        referralLink: state.referral.referralLink,
                        referralCode: state.referral.referralCode,
                      ),
                      const SizedBox(height: 16),

                      // "How it works" section - en un Expanded para que se adapte al espacio disponible
                      const Expanded(child: HowItWorksWidget()),
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
                        'Error loading invitations',
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
                          // Try to get current customer details
                          final customerState = context
                              .read<CustomerDetailsBloc>()
                              .state;
                          if (customerState is CustomerDetailsLoaded) {
                            // If we have details, pass them to the event
                            context.read<InviteBloc>().add(
                              LoadUserReferralEvent(
                                customerDetails: customerState.customerDetails,
                              ),
                            );
                          } else {
                            // If we don't have details, load without them
                            context.read<InviteBloc>().add(
                              const LoadUserReferralEvent(),
                            );
                          }
                        },
                        child: const Text('Retry'),
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
