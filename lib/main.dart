import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:screen_go/screen_go.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:live_chat/core/constant/app_constant.dart';
import 'package:live_chat/core/di/service_locator.dart';
import 'package:live_chat/core/helper/cache_helper.dart';
import 'package:live_chat/core/network/network_cubit.dart';
import 'package:live_chat/core/routing/app_router.dart';
import 'package:live_chat/core/routing/routes.dart';
import 'package:live_chat/core/theme/app_theme.dart';
import 'package:live_chat/core/theme/theme_cubit.dart';

import 'package:live_chat/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:live_chat/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:live_chat/features/friends/presentation/cubit/friends_cubit.dart';
import 'package:live_chat/features/home/presentation/cubit/home_cubit.dart';
import 'package:live_chat/features/market/presentation/cubit/market_cubit.dart';
import 'package:live_chat/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:live_chat/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:live_chat/generated/l10n.dart';

SharedPreferences? sharedPreferences;

bool get pref => sl.isRegistered<ThemeCubit>()
    ? sl<ThemeCubit>().isDarkMode
    : (CacheHelper.getBool(key: AppConstants.isDarkModeKey) ?? false);

set pref(bool? value) {
  if (value != null && sl.isRegistered<ThemeCubit>()) {
    sl<ThemeCubit>().setTheme(value);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Clean Architecture Service Locator (GetIt & SharedPreferences singleton)
  await initServiceLocator();
  sharedPreferences = sl<SharedPreferences>();

  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBXoxdZGdgH8ORanE8x9jgiu0n7s9buFCc",
        authDomain: "ngoum-cf658.firebaseapp.com",
        projectId: "ngoum-cf658",
        storageBucket: "ngoum-cf658.firebasestorage.app",
        messagingSenderId: "273991677038",
        appId: "1:273991677038:web:d71d9b0e9a53fd6b23a27f",
        measurementId: "G-DBVLDMKBXK",
      ),
    );
  } catch (e) {
    debugPrint("Firebase init note: $e");
  }

  // 2. Initialize device ID & FCM token via AuthCubit
  await sl<AuthCubit>().initDeviceIdAndToken();

  final String initialLocale = CacheHelper.getString(key: "selectedLanguage") ?? 'ar';
  await CacheHelper.saveData(key: "selectedLanguage", value: initialLocale);

  final String? savedPage = CacheHelper.getString(key: AppConstants.pageKey);
  final String initialRoute = savedPage == 'Home' ? Routes.homeScreen : Routes.splashScreen;

  runApp(MyApp(initialLocale: initialLocale, initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialLocale;
  final String initialRoute;

  const MyApp({
    super.key,
    required this.initialLocale,
    required this.initialRoute,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>.value(value: sl<ThemeCubit>()),
        BlocProvider<NetworkCubit>(create: (_) => sl<NetworkCubit>()),
        BlocProvider<AuthCubit>(create: (_) => sl<AuthCubit>()),
        BlocProvider<HomeCubit>(create: (_) => sl<HomeCubit>()),
        BlocProvider<ChatCubit>(create: (_) => sl<ChatCubit>()),
        BlocProvider<FriendsCubit>(create: (_) => sl<FriendsCubit>()),
        BlocProvider<NotificationsCubit>(create: (_) => sl<NotificationsCubit>()),
        BlocProvider<MarketCubit>(create: (_) => sl<MarketCubit>()),
        BlocProvider<SettingsCubit>(create: (_) => sl<SettingsCubit>()),
      ],
      child: ScreenGo(
        materialApp: true,
        builder: (context, deviceInfo) => BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp.router(
              routerConfig: AppRouter.getRouter(initialRoute),
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              locale: Locale(initialLocale),
              localizationsDelegates: const [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              supportedLocales: S.delegate.supportedLocales,
              debugShowCheckedModeBanner: false,
              scrollBehavior: const MaterialScrollBehavior().copyWith(
                dragDevices: {
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.touch,
                  PointerDeviceKind.trackpad,
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
