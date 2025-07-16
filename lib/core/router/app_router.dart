import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/domain/entities/user.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/profile/presentation/bloc/payment_bloc.dart';
import '../../features/auth/presentation/widgets/auth_wrapper_widget.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/profile/presentation/widgets/myuwifiplan/my_uwifi_plan_page.dart';
import '../../features/profile/presentation/widgets/mywallet/add_card_page.dart';
import '../../features/profile/presentation/widgets/mywallet/add_user_page.dart';
import '../../features/profile/presentation/widgets/mywallet/wallet_page.dart';
import '../../features/profile/presentation/widgets/uwifistore/product_details_page.dart';
import '../../features/profile/presentation/widgets/uwifistore/shopping_cart_page.dart';
import '../../features/profile/presentation/widgets/uwifistore/uwifi_store_page.dart';

class AppRouter {
  static const String root = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String onboarding = '/onboarding';
  static const String wallet = '/wallet';
  static const String addUser = '/adduser';
  static const String addCard = '/addcard';
  static const String uwifiStore = '/uwifistore';
  static const String productDetails = '/productdetails';
  static const String shoppingCart = '/shoppingcart';
  static const String myUwifiPlan = '/myuwifiplan';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case root:
        return MaterialPageRoute(builder: (_) => const AuthWrapperWidget());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case onboarding:
        final args = settings.arguments as Map<String, dynamic>?;
        final User? user = args?['user'];
        return MaterialPageRoute(builder: (_) => OnboardingPage(user: user));
      case wallet:
        return MaterialPageRoute(builder: (_) => const WalletPage());
      case addUser:
        return MaterialPageRoute(builder: (_) => const AddUserPage());
      case addCard:
        return MaterialPageRoute(
          builder: (context) => MultiBlocProvider(
            providers: [
              BlocProvider.value(
                value: BlocProvider.of<PaymentBloc>(context),
              ),
              BlocProvider.value(
                value: BlocProvider.of<AuthBloc>(context),
              ),
            ],
            child: const AddCardPage(),
          ),
        );
      case uwifiStore:
        return MaterialPageRoute(builder: (_) => const UwifiStorePage());
      case productDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => ProductDetailsPage(product: args),
        );
      case shoppingCart:
        return MaterialPageRoute(builder: (_) => const ShoppingCartPage());
      case myUwifiPlan:
        return MaterialPageRoute(builder: (_) => const MyUwifiPlanPage());
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Ruta no encontrada'))),
        );
    }
  }
}
