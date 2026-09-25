import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:live_chat/core/api/api_consumer.dart';
import 'package:live_chat/core/api/dio_consumer.dart';
import 'package:live_chat/core/helper/cache_helper.dart';
import 'package:live_chat/core/network/network_cubit.dart';
import 'package:live_chat/core/network/network_info.dart';
import 'package:live_chat/core/services/audio/audio_service.dart';
import 'package:live_chat/core/services/pusher/pusher_service.dart';
import 'package:live_chat/core/theme/theme_cubit.dart';

import 'package:live_chat/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:live_chat/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:live_chat/features/auth/domain/repositories/auth_repository.dart';
import 'package:live_chat/features/auth/presentation/cubit/auth_cubit.dart';

import 'package:live_chat/features/home/data/datasources/home_remote_data_source.dart';
import 'package:live_chat/features/home/data/repositories/home_repository_impl.dart';
import 'package:live_chat/features/home/domain/repositories/home_repository.dart';
import 'package:live_chat/features/home/presentation/cubit/home_cubit.dart';

import 'package:live_chat/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:live_chat/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:live_chat/features/chat/domain/repositories/chat_repository.dart';
import 'package:live_chat/features/chat/presentation/cubit/chat_cubit.dart';

import 'package:live_chat/features/friends/data/datasources/friends_remote_data_source.dart';
import 'package:live_chat/features/friends/data/repositories/friends_repository_impl.dart';
import 'package:live_chat/features/friends/domain/repositories/friends_repository.dart';
import 'package:live_chat/features/friends/presentation/cubit/friends_cubit.dart';

import 'package:live_chat/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:live_chat/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:live_chat/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:live_chat/features/notifications/presentation/cubit/notifications_cubit.dart';

import 'package:live_chat/features/market/data/datasources/market_remote_data_source.dart';
import 'package:live_chat/features/market/data/repositories/market_repository_impl.dart';
import 'package:live_chat/features/market/domain/repositories/market_repository.dart';
import 'package:live_chat/features/market/presentation/cubit/market_cubit.dart';

import 'package:live_chat/features/settings/data/datasources/settings_remote_data_source.dart';
import 'package:live_chat/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:live_chat/features/settings/domain/repositories/settings_repository.dart';
import 'package:live_chat/features/settings/presentation/cubit/settings_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> initServiceLocator() async {
  // 1. SharedPreferences & CacheHelper
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  CacheHelper.sharedPreferences = sharedPreferences;

  // 2. Dio & Network Consumer
  sl.registerLazySingleton<Dio>(() => Dio());
  sl.registerLazySingleton<ApiConsumer>(() => DioConsumer(dio: sl<Dio>()));

  // 3. Network Connectivity
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfo(sl<Connectivity>()));
  sl.registerFactory<NetworkCubit>(() => NetworkCubit(sl<NetworkInfo>()));

  // 4. Core Services
  sl.registerLazySingleton<AudioService>(() => JustAudioServiceImpl());
  sl.registerLazySingleton<PusherService>(() => PusherService());

  // 5. Global Theme Cubit
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit());

  // 6. Auth Feature
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(api: sl<ApiConsumer>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl<AuthRemoteDataSource>()),
  );
  sl.registerFactory<AuthCubit>(
    () => AuthCubit(authRepository: sl<AuthRepository>()),
  );

  // 7. Home Feature
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(api: sl<ApiConsumer>()),
  );
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(remoteDataSource: sl<HomeRemoteDataSource>()),
  );
  sl.registerFactory<HomeCubit>(
    () => HomeCubit(homeRepository: sl<HomeRepository>()),
  );

  // 8. Chat Feature
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(api: sl<ApiConsumer>()),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(remoteDataSource: sl<ChatRemoteDataSource>()),
  );
  sl.registerFactory<ChatCubit>(
    () => ChatCubit(
      chatRepository: sl<ChatRepository>(),
      pusherService: sl<PusherService>(),
      audioService: sl<AudioService>(),
    ),
  );

  // 9. Friends Feature
  sl.registerLazySingleton<FriendsRemoteDataSource>(
    () => FriendsRemoteDataSourceImpl(api: sl<ApiConsumer>()),
  );
  sl.registerLazySingleton<FriendsRepository>(
    () => FriendsRepositoryImpl(remoteDataSource: sl<FriendsRemoteDataSource>()),
  );
  sl.registerFactory<FriendsCubit>(
    () => FriendsCubit(friendsRepository: sl<FriendsRepository>()),
  );

  // 10. Notifications Feature
  sl.registerLazySingleton<NotificationsRemoteDataSource>(
    () => NotificationsRemoteDataSourceImpl(api: sl<ApiConsumer>()),
  );
  sl.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(remoteDataSource: sl<NotificationsRemoteDataSource>()),
  );
  sl.registerFactory<NotificationsCubit>(
    () => NotificationsCubit(notificationsRepository: sl<NotificationsRepository>()),
  );

  // 11. Market Feature
  sl.registerLazySingleton<MarketRemoteDataSource>(
    () => MarketRemoteDataSourceImpl(api: sl<ApiConsumer>()),
  );
  sl.registerLazySingleton<MarketRepository>(
    () => MarketRepositoryImpl(remoteDataSource: sl<MarketRemoteDataSource>()),
  );
  sl.registerFactory<MarketCubit>(
    () => MarketCubit(marketRepository: sl<MarketRepository>()),
  );

  // 12. Settings Feature
  sl.registerLazySingleton<SettingsRemoteDataSource>(
    () => SettingsRemoteDataSourceImpl(api: sl<ApiConsumer>()),
  );
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(remoteDataSource: sl<SettingsRemoteDataSource>()),
  );
  sl.registerFactory<SettingsCubit>(
    () => SettingsCubit(settingsRepository: sl<SettingsRepository>()),
  );
}