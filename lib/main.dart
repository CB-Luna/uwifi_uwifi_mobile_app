import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'core/bootstrap/app_bootstrapper.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/utils/app_logger.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/reset_password_bloc.dart';
import 'features/auth/presentation/widgets/auth_wrapper_widget.dart';
import 'features/home/presentation/bloc/data_usage_bloc.dart';
import 'features/home/presentation/bloc/transaction_bloc.dart';
import 'features/invite/presentation/bloc/invite_bloc.dart';
import 'features/profile/presentation/bloc/payment_bloc.dart';
import 'features/profile/presentation/bloc/wallet_bloc.dart';
import 'features/profile/presentation/widgets/uwifistore/cart_provider.dart';
import 'features/videos/presentation/bloc/genres_bloc.dart';
import 'features/videos/presentation/bloc/genres_event.dart';
import 'features/videos/presentation/bloc/video_explorer_bloc.dart';
import 'features/videos/presentation/bloc/videos_bloc.dart';
import 'injection_container.dart' as di;

void main() async {
  // Inicializar la aplicación usando el bootstrapper
  await AppBootstrapper.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) {
            final authBloc = di.getIt<AuthBloc>();
            AppLogger.authInfo(
              'Creating AuthBloc instance - ${authBloc.hashCode}',
            );
            // Verificar el estado de autenticación al iniciar
            authBloc.add(CheckAuthStatus());
            return authBloc;
          },
        ),
        // ✅ Agregar VideosBloc a nivel global para evitar conflictos de contexto
        BlocProvider<VideosBloc>(
          create: (context) {
            AppLogger.videoInfo('Creating global VideosBloc instance');
            return di.getIt<VideosBloc>();
          },
        ),
        // ✅ Agregar GenresBloc a nivel global para el manejo de categorías
        BlocProvider<GenresBloc>(
          create: (context) {
            final genresBloc = di.getIt<GenresBloc>();
            AppLogger.categoryInfo('Creating global GenresBloc instance');
            // Cargar las categorías al inicializar
            genresBloc.add(const LoadGenresEvent());
            return genresBloc;
          },
        ),
        // ✅ Agregar VideoExplorerBloc a nivel global para evitar errores de provider
        BlocProvider<VideoExplorerBloc>(
          create: (context) {
            AppLogger.videoInfo('Creating global VideoExplorerBloc instance');
            return di.getIt<VideoExplorerBloc>();
          },
        ),
        // ✅ Agregar InviteBloc a nivel global para el feature de invitaciones
        BlocProvider<InviteBloc>(
          create: (context) {
            AppLogger.authInfo('Creating global InviteBloc instance');
            return di.getIt<InviteBloc>();
          },
        ),
        // ✅ Agregar WalletBloc a nivel global para el feature de wallet
        BlocProvider<WalletBloc>(create: (_) => di.getIt<WalletBloc>()),
        BlocProvider<PaymentBloc>(create: (_) => di.getIt<PaymentBloc>()),
        BlocProvider<TransactionBloc>(
          create: (_) => di.getIt<TransactionBloc>(),
        ),
        BlocProvider<ResetPasswordBloc>(
          create: (_) => di.getIt<ResetPasswordBloc>(),
        ),
        // Añadir DataUsageBloc para el feature de uso de datos
        BlocProvider<DataUsageBloc>(
          create: (_) => di.getIt<DataUsageBloc>(),
        ),
      ],
      child: ChangeNotifierProvider(
        create: (context) => CartProvider(),
        child: Builder(
          builder: (context) {
            // ✅ Usar Builder para asegurar acceso correcto al contexto de BLoCs
            return MaterialApp(
              title: AppConstants.appName,
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
                useMaterial3: true,
                appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                cardTheme: CardThemeData(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              // ✅ Usar home en lugar de initialRoute para evitar conflictos del Navigator
              home: const AuthWrapperWidget(),
              onGenerateRoute: AppRouter.generateRoute,
            );
          },
        ),
      ),
    );
  }
}
