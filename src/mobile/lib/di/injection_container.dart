import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/oauth_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/network_info.dart';
import '../core/network/secure_http_client.dart';
import '../data/datasources/auth/auth_remote_data_source.dart';
import '../data/datasources/auth/google_auth_service.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/auth/google_sign_in.dart';
import '../domain/usecases/auth/login.dart';
import '../domain/usecases/auth/registration.dart';
import '../presentation/providers/auth_provider.dart';
import '../presentation/providers/theme_provider.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Providers
  sl.registerFactory(
    () => AuthProvider(
      repository: sl(),
      loginUseCase: sl(),
      registrationUseCase: sl(),
      googleSignInUseCase: sl(),
      googleSignIn: sl(),
      prefs: sl(),
    ),
  );
  sl.registerFactory(() => ThemeProvider());

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegistrationUseCase(sl()));
  sl.registerLazySingleton(() => GoogleSignInUseCase(sl()));

  sl.registerLazySingleton(
    () => GoogleAuthService(googleSignIn: sl(), prefs: sl()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
      googleSignIn: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () =>
        AuthRemoteDataSourceImpl(client: sl(), googleSignIn: sl(), prefs: sl()),
  );

  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      sl<Dio>(),
      sl<SharedPreferences>(),
      onLogoutRequired: () {
        if (sl.isRegistered<AuthProvider>()) {
          sl<AuthProvider>().forceLogout();
        }
      },
    ),
  );

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Create and register a secure Dio instance
  final dio = await SecureHttpClient.createDio();
  sl.registerLazySingleton(() => dio);

  sl.registerLazySingleton(() => Connectivity());

  sl.registerLazySingleton(
    () => GoogleSignIn(
      scopes: ['email', 'profile', 'openid'],
      serverClientId: GoogleOAuthConstants.WEB_CLIENT_ID,
    ),
  );
}
