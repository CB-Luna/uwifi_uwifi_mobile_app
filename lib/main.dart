import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'core/bootstrap/app_bootstrapper.dart';
import 'core/constants/app_constants.dart';
import 'core/providers/biometric_provider.dart';
import 'core/router/app_router.dart';
import 'core/utils/ad_manager.dart';
import 'core/utils/app_logger.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/reset_password_bloc.dart';
import 'features/customer/presentation/bloc/customer_details_bloc.dart';
import 'features/customer/presentation/widgets/customer_details_listener.dart';
import 'features/home/presentation/bloc/data_usage_bloc.dart';
import 'features/home/presentation/bloc/traffic_bloc.dart';
import 'features/home/presentation/bloc/transaction_bloc.dart';
import 'features/invite/presentation/bloc/invite_bloc.dart';
import 'features/profile/presentation/bloc/payment_bloc.dart';
import 'features/profile/presentation/bloc/wallet_bloc.dart';
import 'features/profile/presentation/widgets/uwifistore/cart_provider.dart';
import 'features/splash/presentation/pages/splash_screen.dart';
import 'features/videos/presentation/bloc/genres_bloc.dart';
import 'features/videos/presentation/bloc/genres_event.dart';
import 'features/videos/presentation/bloc/video_explorer_bloc.dart';
import 'features/videos/presentation/bloc/videos_bloc.dart';
import 'injection_container.dart' as di;

void main() async {
  // Inicializar la aplicación usando el bootstrapper
  await AppBootstrapper.initialize();

  // Inicializar el SDK de Google Mobile Ads
  await AdManager.initialize();

  // Configurar el modo inmersivo para ocultar la barra de navegación del sistema
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top],
  );

  // Configurar la orientación de la aplicación
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configurar el color de la barra de estado
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

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
        // ✅ Add VideosBloc at global level to avoid context conflicts
        BlocProvider<VideosBloc>(
          create: (context) {
            AppLogger.videoInfo('Creating global VideosBloc instance');
            return di.getIt<VideosBloc>();
          },
        ),
        // ✅ Add GenresBloc at global level for categories management
        BlocProvider<GenresBloc>(
          create: (context) {
            final genresBloc = di.getIt<GenresBloc>();
            AppLogger.categoryInfo('Creating global GenresBloc instance');
            // Cargar las categorías al inicializar
            genresBloc.add(const LoadGenresEvent());
            return genresBloc;
          },
        ),
        // ✅ Add VideoExplorerBloc at global level to avoid provider errors
        BlocProvider<VideoExplorerBloc>(
          create: (context) {
            AppLogger.videoInfo('Creating global VideoExplorerBloc instance');
            return di.getIt<VideoExplorerBloc>();
          },
        ),
        // ✅ Add InviteBloc at global level for the invitations feature
        BlocProvider<InviteBloc>(
          create: (context) {
            AppLogger.authInfo('Creating global InviteBloc instance');
            return di.getIt<InviteBloc>();
          },
        ),
        // ✅ Add WalletBloc at global level for the wallet feature
        BlocProvider<WalletBloc>(create: (_) => di.getIt<WalletBloc>()),
        BlocProvider<PaymentBloc>(create: (_) => di.getIt<PaymentBloc>()),
        BlocProvider<TransactionBloc>(
          create: (_) => di.getIt<TransactionBloc>(),
        ),
        BlocProvider<ResetPasswordBloc>(
          create: (_) => di.getIt<ResetPasswordBloc>(),
        ),
        // Add DataUsageBloc for the data usage feature
        BlocProvider<DataUsageBloc>(create: (_) => di.getIt<DataUsageBloc>()),
        // Add TrafficBloc for the data usage in bar chart feature
        BlocProvider<TrafficBloc>(create: (_) => di.getIt<TrafficBloc>()),
        // Add CustomerDetailsBloc for the customer details feature
        BlocProvider<CustomerDetailsBloc>(
          create: (_) => di.getIt<CustomerDetailsBloc>(),
        ),
      ],
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => CartProvider()),
          ChangeNotifierProvider(
            create: (context) => di.getIt<BiometricProvider>(),
          ),
        ],
        child: Builder(
          builder: (context) {
            // ✅ Use Builder to ensure correct access to BLoC context
            // Wrap the application with CustomerDetailsListener to load customer details after login
            return CustomerDetailsListener(
              child: MaterialApp(
                title: AppConstants.appName,
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
                  useMaterial3: true,
                  appBarTheme: const AppBarTheme(
                    centerTitle: true,
                    elevation: 0,
                  ),
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
                // ✅ Use home instead of initialRoute to avoid Navigator conflicts
                home: const SplashScreen(),
                onGenerateRoute: AppRouter.generateRoute,
              ),
            );
          },
        ),
      ),
    );
  }
}
