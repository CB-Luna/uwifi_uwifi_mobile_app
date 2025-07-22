import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/customer_details_bloc.dart';

/// Widget that listens for changes in authentication state and loads
/// customer details when the user authenticates.
class CustomerDetailsListener extends StatelessWidget {
  final Widget child;

  const CustomerDetailsListener({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // When the user authenticates, we load the customer details
          // Convert the user ID to integer for the FetchCustomerDetails event
          final customerId = int.tryParse(state.user.id) ?? 0;
          if (customerId > 0) {
            BlocProvider.of<CustomerDetailsBloc>(
              context,
            ).add(FetchCustomerDetails(customerId));
          }
        }
      },
      child: child,
    );
  }
}
