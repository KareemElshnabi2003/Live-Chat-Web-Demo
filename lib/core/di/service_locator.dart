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

// Auth Feature
import 'package:live_chat/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:live_chat/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:live_chat/features/auth/domain/repositories/auth_repository.dart';
import 'package:live_chat/features/auth/domain/usecases/check_otp_use_case.dart';
import 'package:live_chat/features/auth/domain/usecases/login_use_case.dart';
import 'package:live_chat/features/auth/domain/usecases/logout_use_case.dart';
import 'package:live_chat/features/auth/domain/usecases/register_use_case.dart';
import 'package:live_chat/features/auth/domain/usecases/resend_otp_use_case.dart';
import 'package:live_chat/features/auth/domain/usecases/verify_guest_use_case.dart';
import 'package:live_chat/features/auth/presentation/cubit/auth_cubit.dart';

// Home Feature
import 'package:live_chat/features/home/data/datasources/home_remote_data_source.dart';
import 'package:live_chat/features/home/data/repositories/home_repository_impl.dart';
import 'package:live_chat/features/home/domain/repositories/home_repository.dart';
import 'package:live_chat/features/home/domain/usecases/home_use_cases.dart';
import 'package:live_chat/features/home/presentation/cubit/home_cubit.dart';
import 'package:live_chat/features/home/presentation/cubit/pin_chat_cubit.dart';

// Chat Feature
import 'package:live_chat/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:live_chat/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:live_chat/features/chat/domain/repositories/chat_repository.dart';
import 'package:live_chat/features/chat/domain/usecases/chat_use_cases.dart';
import 'package:live_chat/features/chat/presentation/cubit/chat_cubit.dart';

// Friends Feature
import 'package:live_chat/features/friends/data/datasources/friends_remote_data_source.dart';
import 'package:live_chat/features/friends/data/repositories/friends_repository_impl.dart';
import 'package:live_chat/features/friends/domain/repositories/friends_repository.dart';
import 'package:live_chat/features/friends/domain/usecases/friends_use_cases.dart';
import 'package:live_chat/features/friends/presentation/cubit/friends_cubit.dart';

// Notifications Feature
import 'package:live_chat/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:live_chat/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:live_chat/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:live_chat/features/notifications/domain/usecases/notifications_use_cases.dart';
import 'package:live_chat/features/notifications/presentation/cubit/notifications_cubit.dart';

// Market Feature
import 'package:live_chat/features/market/data/datasources/market_remote_data_source.dart';
import 'package:live_chat/features/market/data/repositories/market_repository_impl.dart';
import 'package:live_chat/features/market/domain/repositories/market_repository.dart';
import 'package:live_chat/features/market/domain/usecases/market_use_cases.dart';
import 'package:live_chat/features/market/presentation/cubit/market_cubit.dart';

// Settings Feature
import 'package:live_chat/features/settings/data/datasources/settings_remote_data_source.dart';
import 'package:live_chat/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:live_chat/features/settings/domain/repositories/settings_repository.dart';
import 'package:live_chat/features/settings/domain/usecases/settings_use_cases.dart';
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
  sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton<RegisterUseCase>(() => RegisterUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton<CheckOtpUseCase>(() => CheckOtpUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton<ResendOtpUseCase>(() => ResendOtpUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton<VerifyGuestUseCase>(() => VerifyGuestUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton<LogoutUseCase>(() => LogoutUseCase(sl<AuthRepository>()));

  sl.registerFactory<AuthCubit>(
    () => AuthCubit(
      loginUseCase: sl<LoginUseCase>(),
      registerUseCase: sl<RegisterUseCase>(),
      checkOtpUseCase: sl<CheckOtpUseCase>(),
      resendOtpUseCase: sl<ResendOtpUseCase>(),
      verifyGuestUseCase: sl<VerifyGuestUseCase>(),
      logoutUseCase: sl<LogoutUseCase>(),
    ),
  );

  // 7. Home Feature
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(api: sl<ApiConsumer>()),
  );
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(remoteDataSource: sl<HomeRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetAdsUseCase>(() => GetAdsUseCase(sl<HomeRepository>()));
  sl.registerLazySingleton<GetPinnedChatUseCase>(() => GetPinnedChatUseCase(sl<HomeRepository>()));
  sl.registerLazySingleton<GetRecentChatsUseCase>(() => GetRecentChatsUseCase(sl<HomeRepository>()));
  sl.registerLazySingleton<GetSystemChatsUseCase>(() => GetSystemChatsUseCase(sl<HomeRepository>()));
  sl.registerLazySingleton<GetUserChatsUseCase>(() => GetUserChatsUseCase(sl<HomeRepository>()));

  sl.registerFactory<HomeCubit>(
    () => HomeCubit(homeRepository: sl<HomeRepository>()),
  );
  sl.registerFactory<PinChatCubit>(
    () => PinChatCubit(
      homeRepository: sl<HomeRepository>(),
      marketRepository: sl<MarketRepository>(),
    ),
  );

  // 8. Chat Feature
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(api: sl<ApiConsumer>()),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(remoteDataSource: sl<ChatRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetMessagesUseCase>(() => GetMessagesUseCase(sl<ChatRepository>()));
  sl.registerLazySingleton<SendMessageUseCase>(() => SendMessageUseCase(sl<ChatRepository>()));
  sl.registerLazySingleton<SendMessageWithFileUseCase>(() => SendMessageWithFileUseCase(sl<ChatRepository>()));
  sl.registerLazySingleton<SendReactionUseCase>(() => SendReactionUseCase(sl<ChatRepository>()));
  sl.registerLazySingleton<GetMembersUseCase>(() => GetMembersUseCase(sl<ChatRepository>()));
  sl.registerLazySingleton<GetRadiosUseCase>(() => GetRadiosUseCase(sl<ChatRepository>()));
  sl.registerLazySingleton<GetThemesUseCase>(() => GetThemesUseCase(sl<ChatRepository>()));
  sl.registerLazySingleton<CreateGeneralChatUseCase>(() => CreateGeneralChatUseCase(sl<ChatRepository>()));
  sl.registerLazySingleton<UpdateGeneralChatUseCase>(() => UpdateGeneralChatUseCase(sl<ChatRepository>()));
  sl.registerLazySingleton<DeleteChatUseCase>(() => DeleteChatUseCase(sl<ChatRepository>()));
  sl.registerLazySingleton<AcceptMemberToChatUseCase>(() => AcceptMemberToChatUseCase(sl<ChatRepository>()));
  sl.registerLazySingleton<BlockOrUnBlockUseCase>(() => BlockOrUnBlockUseCase(sl<ChatRepository>()));
  sl.registerLazySingleton<CreateChatFriendUseCase>(() => CreateChatFriendUseCase(sl<ChatRepository>()));

  sl.registerFactory<ChatCubit>(
    () => ChatCubit(
      getMessagesUseCase: sl<GetMessagesUseCase>(),
      sendMessageUseCase: sl<SendMessageUseCase>(),
      sendMessageWithFileUseCase: sl<SendMessageWithFileUseCase>(),
      sendReactionUseCase: sl<SendReactionUseCase>(),
      getMembersUseCase: sl<GetMembersUseCase>(),
      getRadiosUseCase: sl<GetRadiosUseCase>(),
      getThemesUseCase: sl<GetThemesUseCase>(),
      createGeneralChatUseCase: sl<CreateGeneralChatUseCase>(),
      updateGeneralChatUseCase: sl<UpdateGeneralChatUseCase>(),
      deleteChatUseCase: sl<DeleteChatUseCase>(),
      acceptMemberToChatUseCase: sl<AcceptMemberToChatUseCase>(),
      blockOrUnBlockUseCase: sl<BlockOrUnBlockUseCase>(),
      createChatFriendUseCase: sl<CreateChatFriendUseCase>(),
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
  sl.registerLazySingleton<GetFriendsUseCase>(() => GetFriendsUseCase(sl<FriendsRepository>()));
  sl.registerLazySingleton<GetSuggestedFriendsUseCase>(() => GetSuggestedFriendsUseCase(sl<FriendsRepository>()));
  sl.registerLazySingleton<SendFriendRequestUseCase>(() => SendFriendRequestUseCase(sl<FriendsRepository>()));
  sl.registerLazySingleton<AcceptOrRejectFriendUseCase>(() => AcceptOrRejectFriendUseCase(sl<FriendsRepository>()));
  sl.registerLazySingleton<RemoveFriendUseCase>(() => RemoveFriendUseCase(sl<FriendsRepository>()));

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
  sl.registerLazySingleton<GetNotificationsUseCase>(() => GetNotificationsUseCase(sl<NotificationsRepository>()));

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
  sl.registerLazySingleton<GetMarketProfileUseCase>(() => GetMarketProfileUseCase(sl<MarketRepository>()));
  sl.registerLazySingleton<GetStorePowersUseCase>(() => GetStorePowersUseCase(sl<MarketRepository>()));
  sl.registerLazySingleton<ClosePowerUseCase>(() => ClosePowerUseCase(sl<MarketRepository>()));
  sl.registerLazySingleton<GetPaymentOptionsUseCase>(() => GetPaymentOptionsUseCase(sl<MarketRepository>()));
  sl.registerLazySingleton<SubmitManualPaymentUseCase>(() => SubmitManualPaymentUseCase(sl<MarketRepository>()));
  sl.registerLazySingleton<GetAvailableTimeSlotsUseCase>(() => GetAvailableTimeSlotsUseCase(sl<MarketRepository>()));
  sl.registerLazySingleton<PinChatUseCase>(() => PinChatUseCase(sl<MarketRepository>()));

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
  sl.registerLazySingleton<GetProfileUseCase>(() => GetProfileUseCase(sl<SettingsRepository>()));
  sl.registerLazySingleton<UpdateProfileUseCase>(() => UpdateProfileUseCase(sl<SettingsRepository>()));
  sl.registerLazySingleton<DeleteAccountUseCase>(() => DeleteAccountUseCase(sl<SettingsRepository>()));
  sl.registerLazySingleton<ChangeMobileThemeUseCase>(() => ChangeMobileThemeUseCase(sl<SettingsRepository>()));
  sl.registerLazySingleton<GetPrivacyPolicyUseCase>(() => GetPrivacyPolicyUseCase(sl<SettingsRepository>()));
  sl.registerLazySingleton<GetTermsUseCase>(() => GetTermsUseCase(sl<SettingsRepository>()));
  sl.registerLazySingleton<GetAdsWithUsUseCase>(() => GetAdsWithUsUseCase(sl<SettingsRepository>()));

  sl.registerFactory<SettingsCubit>(
    () => SettingsCubit(settingsRepository: sl<SettingsRepository>()),
  );
}