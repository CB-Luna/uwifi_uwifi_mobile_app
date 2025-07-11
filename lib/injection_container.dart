import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/videos/data/datasources/videos_remote_data_source.dart';
import 'features/videos/data/datasources/videos_remote_data_source_impl.dart';
import 'features/videos/data/datasources/videos_local_data_source.dart';
import 'features/videos/data/datasources/videos_local_data_source_impl.dart';
import 'features/videos/data/datasources/genres_remote_data_source.dart';
import 'features/videos/data/datasources/genres_remote_data_source_impl.dart';
import 'features/videos/data/repositories/videos_repository_impl.dart';
import 'features/videos/data/repositories/genres_repository_impl.dart';
import 'features/videos/domain/repositories/videos_repository.dart';
import 'features/videos/domain/repositories/genres_repository.dart';
import 'features/videos/domain/usecases/get_videos.dart';
import 'features/videos/domain/usecases/get_videos_paginated.dart';
import 'features/videos/domain/usecases/get_videos_by_genre.dart';
import 'features/videos/domain/usecases/get_video.dart';
import 'features/videos/domain/usecases/like_video.dart';
import 'features/videos/domain/usecases/unlike_video.dart';
import 'features/videos/domain/usecases/mark_video_as_viewed.dart';
import 'features/videos/domain/usecases/get_genres.dart';
import 'features/videos/domain/usecases/get_ads.dart';
import 'features/videos/domain/usecases/get_ads_with_params.dart';
import 'features/videos/domain/usecases/get_genres_with_videos.dart';
import 'features/videos/presentation/bloc/videos_bloc.dart';
import 'features/videos/presentation/bloc/genres_bloc.dart';
import 'features/videos/presentation/bloc/video_explorer_bloc.dart';

import 'core/network/network_info.dart';
import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/services/biometric_auth_service.dart';
import 'features/auth/domain/usecases/get_current_user.dart';
import 'features/auth/domain/usecases/login_user.dart';
import 'features/auth/domain/usecases/logout_user.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

// Invite feature imports
import 'features/invite/data/datasources/invite_local_data_source.dart';
import 'features/invite/data/datasources/invite_local_data_source_impl.dart';
import 'features/invite/data/datasources/invite_remote_data_source.dart';
import 'features/invite/data/datasources/invite_remote_data_source_impl.dart';
import 'features/invite/data/repositories/invite_repository_impl.dart';
import 'features/invite/domain/repositories/invite_repository.dart';
import 'features/invite/domain/usecases/get_user_referral.dart';
import 'features/invite/domain/usecases/share_referral_link.dart';
import 'features/invite/domain/usecases/generate_qr_code.dart';
import 'features/invite/presentation/bloc/invite_bloc.dart';

// Billing feature imports
import 'features/home/data/datasources/billing_remote_data_source.dart';
import 'features/home/data/datasources/billing_remote_data_source_impl.dart';
import 'features/home/data/repositories/billing_repository_impl.dart';
import 'features/home/domain/repositories/billing_repository.dart';
import 'features/home/domain/usecases/get_current_billing_period.dart';
import 'features/home/domain/usecases/get_customer_balance.dart';
import 'features/home/presentation/bloc/billing_bloc.dart';

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
  getIt.registerLazySingleton(() => BiometricAuthService(localAuth: getIt()));

  // Bloc
  getIt.registerLazySingleton(
    () => AuthBloc(
      loginUser: getIt(),
      logoutUser: getIt(),
      getCurrentUser: getIt(),
      biometricAuthService: getIt(),
    ),
  );

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
  getIt.registerLazySingleton<InviteRemoteDataSource>(
    () => InviteRemoteDataSourceImpl(supabaseClient: getIt()),
  );

  getIt.registerLazySingleton<InviteLocalDataSource>(
    () => InviteLocalDataSourceImpl(),
  );

  //! Features - Billing
  // Bloc
  getIt.registerFactory(
    () => BillingBloc(
      getCurrentBillingPeriod: getIt(),
      getCustomerBalance: getIt(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(() => GetCurrentBillingPeriod(getIt()));
  getIt.registerLazySingleton(() => GetCustomerBalance(getIt()));

  // Repository
  getIt.registerLazySingleton<BillingRepository>(
    () => BillingRepositoryImpl(
      remoteDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  // Data sources
  getIt.registerLazySingleton<BillingRemoteDataSource>(
    () => BillingRemoteDataSourceImpl(supabaseClient: getIt()),
  );

  // Use cases
  getIt.registerLazySingleton(() => LoginUser(getIt()));
  getIt.registerLazySingleton(() => LogoutUser(getIt()));
  getIt.registerLazySingleton(() => GetCurrentUser(getIt()));

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

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);

  getIt.registerLazySingleton(() => InternetConnectionChecker.createInstance());

  getIt.registerLazySingleton(() => LocalAuthentication());

  // Supabase client will be registered after initialization
}

void registerSupabaseClient(SupabaseClient client) {
  getIt.registerLazySingleton(() => client);
}
