import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/customer_details_bloc.dart';

/// Widget que escucha los cambios en el estado de autenticación y carga
/// los detalles del cliente cuando el usuario se autentica.
class CustomerDetailsListener extends StatelessWidget {
  final Widget child;

  const CustomerDetailsListener({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Cuando el usuario se autentica, cargamos los detalles del cliente
          // Convertir el ID del usuario a entero para el evento FetchCustomerDetails
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
