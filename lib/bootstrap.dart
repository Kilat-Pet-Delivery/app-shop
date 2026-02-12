import 'package:get_it/get_it.dart';

import 'core/config/app_config.dart';
import 'core/network/api_client.dart';
import 'core/network/auth_interceptor.dart';
import 'core/router/app_router.dart';
import 'core/storage/secure_storage.dart';
import 'core/websocket/ws_manager.dart';

import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

import 'features/shop_setup/data/repositories/shop_repository_impl.dart';
import 'features/shop_setup/domain/repositories/shop_repository.dart';
import 'features/shop_setup/presentation/cubit/shop_setup_cubit.dart';

import 'features/shop_dashboard/presentation/cubit/shop_dashboard_cubit.dart';

import 'features/profile/presentation/cubit/profile_cubit.dart';

import 'features/notification/data/repositories/notification_repository_impl.dart';
import 'features/notification/domain/repositories/notification_repository.dart';
import 'features/notification/presentation/cubit/notification_cubit.dart';
import 'features/notification/presentation/cubit/notification_preferences_cubit.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  // Config
  getIt.registerSingleton<AppConfig>(AppConfig.dev());

  // Storage
  getIt.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(),
  );

  // Network
  getIt.registerLazySingleton<AuthInterceptor>(
    () => AuthInterceptor(storage: getIt(), config: getIt()),
  );
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(config: getIt(), authInterceptor: getIt()),
  );
  getIt.registerLazySingleton<WebSocketManager>(
    () => WebSocketManager(storage: getIt(), config: getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<ShopRepository>(
    () => ShopRepositoryImpl(getIt<ApiClient>().dio),
  );
  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(getIt()),
  );

  // Blocs & Cubits
  getIt.registerLazySingleton<AuthBloc>(
    () => AuthBloc(authRepository: getIt(), storage: getIt()),
  );
  getIt.registerFactory<ShopSetupCubit>(
    () => ShopSetupCubit(getIt()),
  );
  getIt.registerLazySingleton<ShopDashboardCubit>(
    () => ShopDashboardCubit(getIt()),
  );
  getIt.registerFactory<ProfileCubit>(
    () => ProfileCubit(getIt(), getIt()),
  );
  getIt.registerFactory<NotificationCubit>(
    () => NotificationCubit(getIt()),
  );
  getIt.registerFactory<NotificationPreferencesCubit>(
    () => NotificationPreferencesCubit(getIt()),
  );

  // Router
  getIt.registerLazySingleton<AppRouter>(
    () => AppRouter(getIt()),
  );
}
