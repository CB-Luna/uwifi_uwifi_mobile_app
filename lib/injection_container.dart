import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uwifiapp/core/utils/app_logger.dart';

import 'core/providers/biometric_provider.dart';
import 'core/services/biometric_preferences_service.dart';

import 'core/network/network_info.dart';
import 'core/services/secure_storage_service.dart';
import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/services/biometric_auth_service.dart';
import 'features/auth/domain/usecases/get_current_user.dart';
import 'features/auth/domain/usecases/login_user.dart';
import 'features/auth/domain/usecases/logout_user.dart';
import 'features/auth/domain/usecases/reset_password.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/reset_password_bloc.dart';
import 'features/customer/data/datasources/customer_local_data_source.dart';
// Customer Details imports
import 'features/customer/data/datasources/customer_remote_data_source.dart';
import 'features/customer/data/repositories/customer_repository_impl.dart';
import 'features/customer/domain/entities/customer_details.dart';
import 'features/customer/domain/repositories/customer_repository.dart';
import 'features/customer/domain/usecases/get_customer_details.dart';
import 'features/customer/presentation/bloc/customer_details_bloc.dart';
// Billing feature imports
import 'features/home/data/datasources/billing_remote_data_source.dart';
import 'features/home/data/datasources/billing_remote_data_source_impl.dart';
// Connection feature imports
import 'features/home/data/datasources/customer_bundle_remote_data_source.dart';
import 'features/home/data/datasources/customer_bundle_remote_data_source_impl.dart';
import 'features/home/data/datasources/device_variable_remote_data_source.dart';
import 'features/home/data/datasources/gateway_info_remote_data_source.dart';
import 'features/home/data/datasources/gateway_info_remote_data_source_impl.dart';
import 'features/home/data/datasources/gateway_operations_remote_data_source.dart';
// Data Usage imports
import 'features/home/data/datasources/gateway_remote_data_source.dart';
// Service
import 'features/home/data/datasources/service_remote_data_source.dart';
import 'features/home/data/datasources/service_remote_data_source_impl.dart';
import 'features/home/data/datasources/traffic_remote_data_source.dart';
import 'features/home/data/datasources/traffic_remote_data_source_impl.dart';
// Transaction imports
import 'features/home/data/datasources/transaction_remote_data_source.dart';
import 'features/home/data/datasources/transaction_remote_data_source_impl.dart';
import 'features/home/data/repositories/billing_repository_impl.dart';
import 'features/home/data/repositories/customer_bundle_repository_impl.dart';
import 'features/home/data/repositories/device_variable_repository_impl.dart';
import 'features/home/data/repositories/gateway_info_repository_impl.dart';
import 'features/home/data/repositories/gateway_operations_repository_impl.dart';
import 'features/home/data/repositories/gateway_repository_impl.dart';
import 'features/home/data/repositories/service_repository_impl.dart';
import 'features/home/data/repositories/traffic_repository_impl.dart';
import 'features/home/data/repositories/transaction_repository_impl.dart';
import 'features/home/domain/repositories/billing_repository.dart';
import 'features/home/domain/repositories/customer_bundle_repository.dart';
import 'features/home/domain/repositories/device_variable_repository.dart';
import 'features/home/domain/repositories/gateway_info_repository.dart';
import 'features/home/domain/repositories/gateway_operations_repository.dart';
import 'features/home/domain/repositories/gateway_repository.dart';
import 'features/home/domain/repositories/service_repository.dart';
import 'features/home/domain/repositories/traffic_repository.dart';
import 'features/home/domain/repositories/transaction_repository.dart';
import 'features/home/domain/usecases/get_current_billing_period.dart';
import 'features/home/domain/usecases/get_customer_active_services.dart';
import 'features/home/domain/usecases/get_customer_balance.dart';
import 'features/home/domain/usecases/get_customer_bundle.dart';
import 'features/home/domain/usecases/get_data_usage.dart';
import 'features/home/domain/usecases/get_gateway_info.dart';
import 'features/home/domain/usecases/get_traffic_information.dart';
import 'features/home/domain/usecases/get_transaction_history.dart';
import 'features/home/domain/usecases/reboot_gateway.dart';
import 'features/home/domain/usecases/update_automatic_charge.dart';
import 'features/home/domain/usecases/update_wifi_network_name.dart';
import 'features/home/domain/usecases/update_wifi_password.dart';
import 'features/home/presentation/bloc/billing_bloc.dart';
import 'features/home/presentation/bloc/connection_bloc.dart';
import 'features/home/presentation/bloc/data_usage_bloc.dart';
import 'features/home/presentation/bloc/service_bloc.dart';
import 'features/home/presentation/bloc/traffic_bloc.dart';
import 'features/home/presentation/bloc/transaction_bloc.dart';
// Invite feature imports
import 'features/invite/data/datasources/invite_local_data_source.dart';
import 'features/invite/data/datasources/invite_local_data_source_impl.dart';
import 'features/invite/data/datasources/invite_remote_data_source.dart';
import 'features/invite/data/datasources/invite_remote_data_source_impl.dart';
import 'features/invite/data/repositories/invite_repository_impl.dart';
import 'features/invite/domain/repositories/invite_repository.dart';
import 'features/invite/domain/usecases/generate_qr_code.dart';
import 'features/invite/domain/usecases/get_user_referral.dart';
import 'features/invite/domain/usecases/share_referral_link.dart';
import 'features/invite/presentation/bloc/invite_bloc.dart';
// Wallet feature imports
import 'features/profile/data/datasources/payment_remote_data_source.dart';
import 'features/profile/data/datasources/payment_remote_data_source_impl.dart';
import 'features/profile/data/datasources/wallet_remote_data_source.dart';
import 'features/profile/data/datasources/wallet_remote_data_source_impl.dart';
import 'features/profile/data/repositories/payment_repository_impl.dart';
import 'features/profile/data/repositories/wallet_repository_impl.dart';
import 'features/profile/domain/repositories/payment_repository.dart';
import 'features/profile/domain/repositories/wallet_repository.dart';
import 'features/profile/domain/usecases/delete_credit_card.dart';
import 'features/profile/domain/usecases/get_affiliated_users.dart';
import 'features/profile/domain/usecases/get_credit_cards.dart';
import 'features/profile/domain/usecases/get_customer_points.dart';
import 'features/profile/domain/usecases/register_new_credit_card.dart';
import 'features/profile/domain/usecases/set_default_card.dart';
import 'features/profile/presentation/bloc/payment_bloc.dart';
import 'features/profile/presentation/bloc/wallet_bloc.dart';
import 'features/videos/data/datasources/genres_remote_data_source.dart';
import 'features/videos/data/datasources/genres_remote_data_source_impl.dart';
import 'features/videos/data/datasources/videos_local_data_source.dart';
import 'features/videos/data/datasources/videos_local_data_source_impl.dart';
import 'features/videos/data/datasources/videos_remote_data_source.dart';
import 'features/videos/data/datasources/videos_remote_data_source_impl.dart';
import 'features/videos/data/repositories/genres_repository_impl.dart';
import 'features/videos/data/repositories/videos_repository_impl.dart';
import 'features/videos/domain/repositories/genres_repository.dart';
import 'features/videos/domain/repositories/videos_repository.dart';
import 'features/videos/domain/usecases/get_ads.dart';
import 'features/videos/domain/usecases/get_ads_with_params.dart';
import 'features/videos/domain/usecases/get_genres.dart';
import 'features/videos/domain/usecases/get_genres_with_videos.dart';
import 'features/videos/domain/usecases/get_video.dart';
import 'features/videos/domain/usecases/get_videos.dart';
import 'features/videos/domain/usecases/get_videos_by_genre.dart';
import 'features/videos/domain/usecases/get_videos_paginated.dart';
import 'features/videos/domain/usecases/like_video.dart';
import 'features/videos/domain/usecases/mark_video_as_viewed.dart';
import 'features/videos/domain/usecases/unlike_video.dart';
import 'features/videos/presentation/bloc/genres_bloc.dart';
import 'features/videos/presentation/bloc/video_explorer_bloc.dart';
import 'features/videos/presentation/bloc/videos_bloc.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  //! Features - Videos
  // Bloc - Cambiado a LazySingleton para asegurar una sola instancia
  getIt.registerLazySingleton(
    () => VideosBloc(
      getVideos: getIt(),
      getVideosPaginated: getIt(),
      getVideosByGenre: getIt(),
      getVideo: getIt(),
      markVideoAsViewed: getIt(),
      likeVideo: getIt(),
      unlikeVideo: getIt(),
    ),
  );

  getIt.registerLazySingleton(() => GenresBloc(getGenres: getIt()));

  // ✅ NUEVO: VideoExplorerBloc para el sistema refactorizado
  getIt.registerFactory(
    () => VideoExplorerBloc(
      getAdsUseCase: getIt(),
      getAdsWithParamsUseCase: getIt(),
      getGenresWithVideosUseCase: getIt(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(() => GetVideos(getIt()));
  getIt.registerLazySingleton(() => GetVideosPaginated(getIt()));
  getIt.registerLazySingleton(() => GetVideosByGenre(getIt()));
  getIt.registerLazySingleton(() => GetVideo(getIt()));
  getIt.registerLazySingleton(() => MarkVideoAsViewed(getIt()));
  getIt.registerLazySingleton(() => LikeVideo(getIt()));
  getIt.registerLazySingleton(() => UnlikeVideo(getIt()));
  getIt.registerLazySingleton(() => GetGenres(getIt()));

  // ✅ NUEVOS: Use cases para el sistema de exploración refactorizado
  getIt.registerLazySingleton(() => GetAds(getIt()));
  getIt.registerLazySingleton(() => GetAdsWithParams(getIt()));
  getIt.registerLazySingleton(() => GetGenresWithVideos(getIt()));

  // Repository
  getIt.registerLazySingleton<VideosRepository>(
    () => VideosRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  getIt.registerLazySingleton<GenresRepository>(
    () => GenresRepositoryImpl(
      remoteDataSource: getIt(),
      videosRemoteDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  // Data sources
  getIt.registerLazySingleton<VideosRemoteDataSource>(
    () => VideosRemoteDataSourceImpl(supabaseClient: getIt()),
  );

  getIt.registerLazySingleton<VideosLocalDataSource>(
    () => VideosLocalDataSourceImpl(sharedPreferences: getIt()),
  );

  getIt.registerLazySingleton<GenresRemoteDataSource>(
    () => GenresRemoteDataSourceImpl(supabaseClient: getIt()),
  );

  //! Features - Auth
  // Services
  getIt.registerLazySingleton<BiometricAuthService>(
    () => BiometricAuthService(
      localAuth: getIt<LocalAuthentication>(),
      preferencesService: getIt<BiometricPreferencesService>(),
      biometricProvider: getIt<BiometricProvider>(),
    ),
  );

  // Auth BLoCs
  getIt.registerFactory(
    () => AuthBloc(
      loginUser: getIt(),
      logoutUser: getIt(),
      getCurrentUser: getIt(),
      biometricAuthService: getIt(),
    ),
  );

  getIt.registerFactory(() => ResetPasswordBloc(resetPassword: getIt()));

  //! Features - Invite
  // Bloc
  getIt.registerLazySingleton(
    () => InviteBloc(
      getUserReferral: getIt(),
      shareReferralLink: getIt(),
      generateQRCode: getIt(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(() => GetUserReferral(getIt()));
  getIt.registerLazySingleton(() => ShareReferralLink(getIt()));
  getIt.registerLazySingleton(() => GenerateQRCode(getIt()));

  // Repository
  getIt.registerLazySingleton<InviteRepository>(
    () => InviteRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  // Data sources
  getIt.registerFactory<InviteRemoteDataSource>(() {
    // Intentar obtener el estado actual del CustomerDetailsBloc
    CustomerDetails? customerDetails;
    try {
      final customerDetailsBloc = getIt<CustomerDetailsBloc>();
      final state = customerDetailsBloc.state;
      if (state is CustomerDetailsLoaded) {
        customerDetails = state.customerDetails;
      }
    } catch (e) {
      // Si el bloc no está disponible o hay algún error, continuamos sin customerDetails
      AppLogger.navError('Error al obtener customerDetails: $e');
    }

    return InviteRemoteDataSourceImpl(
      supabaseClient: getIt(),
      customerDetails: customerDetails,
    );
  });

  getIt.registerLazySingleton<InviteLocalDataSource>(
    () => InviteLocalDataSourceImpl(),
  );

  //! Features - Billing
  // Bloc
  getIt.registerFactory(
    () => BillingBloc(
      getCurrentBillingPeriod: getIt(),
      getCustomerBalance: getIt(),
      updateAutomaticCharge: getIt(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(() => GetCurrentBillingPeriod(getIt()));
  getIt.registerLazySingleton(() => GetCustomerBalance(getIt()));
  getIt.registerLazySingleton(() => UpdateAutomaticCharge(getIt()));

  // Repository
  getIt.registerLazySingleton<BillingRepository>(
    () =>
        BillingRepositoryImpl(remoteDataSource: getIt(), networkInfo: getIt()),
  );

  // Data sources
  getIt.registerLazySingleton<BillingRemoteDataSource>(
    () => BillingRemoteDataSourceImpl(supabaseClient: getIt()),
  );

  //! Features - Wallet
  // Wallet
  getIt.registerFactory(
    () => WalletBloc(getAffiliatedUsers: getIt(), getCustomerPoints: getIt()),
  );

  // Payment
  getIt.registerFactory(
    () => PaymentBloc(
      getCreditCards: getIt(),
      setDefaultCard: getIt(),
      deleteCreditCard: getIt(),
      registerNewCreditCard: getIt(),
    ),
  );

  // Transaction
  getIt.registerFactory(() => TransactionBloc(getTransactionHistory: getIt()));

  // Use cases
  getIt.registerLazySingleton(() => GetAffiliatedUsers(getIt()));
  getIt.registerLazySingleton(() => GetCreditCards(getIt()));
  getIt.registerLazySingleton(() => SetDefaultCard(getIt()));
  getIt.registerLazySingleton(() => DeleteCreditCard(getIt()));
  getIt.registerLazySingleton(() => RegisterNewCreditCard(getIt()));
  getIt.registerLazySingleton(() => GetTransactionHistory(getIt()));
  getIt.registerLazySingleton(() => GetCustomerPoints(getIt()));

  // Repository
  getIt.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(remoteDataSource: getIt(), networkInfo: getIt()),
  );

  getIt.registerLazySingleton<PaymentRepository>(
    () =>
        PaymentRepositoryImpl(remoteDataSource: getIt(), networkInfo: getIt()),
  );

  getIt.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(
      remoteDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  // Data sources
  getIt.registerLazySingleton<WalletRemoteDataSource>(
    () => WalletRemoteDataSourceImpl(supabaseClient: getIt()),
  );

  getIt.registerLazySingleton<TransactionRemoteDataSource>(
    () => TransactionRemoteDataSourceImpl(supabaseClient: getIt()),
  );

  getIt.registerLazySingleton<PaymentRemoteDataSource>(
    () => PaymentRemoteDataSourceImpl(supabaseClient: getIt(), client: getIt()),
  );

  //! Features - Data Usage
  // Blocs
  getIt.registerFactory(() => DataUsageBloc(getDataUsage: getIt()));

  getIt.registerFactory(() => TrafficBloc(getTrafficInformation: getIt()));

  // Use cases
  getIt.registerLazySingleton(() => GetDataUsage(getIt()));
  getIt.registerLazySingleton(() => GetTrafficInformation(getIt()));

  // Repositories
  getIt.registerLazySingleton<GatewayRepository>(
    () =>
        GatewayRepositoryImpl(remoteDataSource: getIt(), networkInfo: getIt()),
  );

  getIt.registerLazySingleton<TrafficRepository>(
    () =>
        TrafficRepositoryImpl(remoteDataSource: getIt(), networkInfo: getIt()),
  );

  // Data sources
  getIt.registerLazySingleton<GatewayRemoteDataSource>(
    () => GatewayRemoteDataSourceImpl(client: getIt()),
  );

  getIt.registerLazySingleton<TrafficRemoteDataSource>(
    () => TrafficRemoteDataSourceImpl(supabaseClient: getIt()),
  );

  //! Features - Service
  // Bloc
  getIt.registerFactory(() => ServiceBloc(getCustomerActiveServices: getIt()));

  // Use cases
  getIt.registerLazySingleton(() => GetCustomerActiveServices(getIt()));

  //! Features - Customer Details
  // Bloc
  getIt.registerFactory(() => CustomerDetailsBloc(getCustomerDetails: getIt()));

  // Use cases
  getIt.registerLazySingleton(() => GetCustomerDetails(getIt()));

  // Repository
  getIt.registerLazySingleton<CustomerRepository>(
    () => CustomerRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  // Data sources
  getIt.registerLazySingleton<CustomerRemoteDataSource>(
    () => CustomerRemoteDataSourceImpl(supabaseClient: getIt()),
  );

  getIt.registerLazySingleton<CustomerLocalDataSource>(
    () => CustomerLocalDataSourceImpl(sharedPreferences: getIt()),
  );

  //! Features - Connection
  // Bloc
  getIt.registerFactory(
    () => ConnectionBloc(
      getCustomerBundle: getIt(),
      getGatewayInfo: getIt(),
      updateWifiNetworkName: getIt(),
      updateWifiPassword: getIt(),
      rebootGateway: getIt(),
      secureStorage: getIt(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(() => GetCustomerBundle(getIt()));
  getIt.registerLazySingleton(() => GetGatewayInfo(getIt()));
  getIt.registerLazySingleton(() => UpdateWifiNetworkName(getIt()));
  getIt.registerLazySingleton(() => UpdateWifiPassword(getIt(), getIt()));
  getIt.registerLazySingleton(() => RebootGateway(getIt()));

  // Repository
  getIt.registerLazySingleton<CustomerBundleRepository>(
    () => CustomerBundleRepositoryImpl(
      remoteDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  getIt.registerLazySingleton<GatewayInfoRepository>(
    () => GatewayInfoRepositoryImpl(
      remoteDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  // Data sources
  getIt.registerLazySingleton<CustomerBundleRemoteDataSource>(
    () => CustomerBundleRemoteDataSourceImpl(supabaseClient: getIt()),
  );

  getIt.registerLazySingleton<GatewayInfoRemoteDataSource>(
    () => GatewayInfoRemoteDataSourceImpl(client: getIt()),
  );

  getIt.registerLazySingleton<DeviceVariableRemoteDataSource>(
    () => DeviceVariableRemoteDataSourceImpl(client: getIt()),
  );

  getIt.registerLazySingleton<DeviceVariableRepository>(
    () => DeviceVariableRepositoryImpl(
      remoteDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  getIt.registerLazySingleton<GatewayOperationsRepository>(
    () => GatewayOperationsRepositoryImpl(
      remoteDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  getIt.registerLazySingleton<GatewayOperationsRemoteDataSource>(
    () => GatewayOperationsRemoteDataSourceImpl(client: getIt()),
  );

  // Repository
  getIt.registerLazySingleton<ServiceRepository>(
    () =>
        ServiceRepositoryImpl(remoteDataSource: getIt(), networkInfo: getIt()),
  );

  // Data sources
  getIt.registerLazySingleton<ServiceRemoteDataSource>(
    () => ServiceRemoteDataSourceImpl(supabaseClient: getIt()),
  );

  // Auth Use Cases
  getIt.registerLazySingleton(() => LoginUser(getIt()));
  getIt.registerLazySingleton(() => LogoutUser(getIt()));
  getIt.registerLazySingleton(() => GetCurrentUser(getIt()));
  getIt.registerLazySingleton(() => ResetPassword(getIt()));
  
  // El servicio de autenticación biométrica ya está registrado arriba

  // Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  // Data sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(supabaseClient: getIt()),
  );

  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: getIt()),
  );

  //! Core
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectionChecker: getIt()),
  );
  getIt.registerLazySingleton(() => SecureStorageService());

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);

  getIt.registerLazySingleton(() => InternetConnectionChecker.createInstance());

  getIt.registerLazySingleton(() => LocalAuthentication());

  // Registrar servicios de biometría
  getIt.registerLazySingleton(() => BiometricPreferencesService());
  getIt.registerFactory(() => BiometricProvider());

  // Registrar http.Client para las llamadas HTTP
  getIt.registerLazySingleton(() => http.Client());

  // Supabase client will be registered after initialization
}

void registerSupabaseClient(SupabaseClient client) {
  getIt.registerLazySingleton(() => client);
}
