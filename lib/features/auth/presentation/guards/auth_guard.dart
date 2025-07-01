import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../../../../core/router/app_router.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          debugPrint('🔒 AuthGuard: Usuario no autenticado, redirigiendo a login');
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRouter.login, 
            (route) => false,
          );
        }
      },
      child: child,
    );
  }
}
