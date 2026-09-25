import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:screen_go/screen_go.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Controller/handel_notification.dart';
import 'Controller/langauge_controller.dart';
import 'Controller/network_controller.dart';
import 'core/Class/api.dart';
import 'core/Class/dynamic_link_service.dart';
import 'core/initial_bindings.dart';
import 'View/Screens/splash/splash_screen.dart';
import 'View/Screens/start page/page_start.dart';
import 'View/Screens/Home/home_view.dart';
import 'View/Screens/auth/auth_view.dart';
import 'View/Screens/create chat/create_chat.dart';
import 'View/Screens/friends/friends.dart';
import 'View/Screens/friends/requests.dart';
import 'View/Screens/suggession friends/suggession friends.dart';
import 'View/Screens/notifications/notifications.dart';
import 'View/Screens/Market/market_page.dart';
import 'View/Screens/settings/setting_view.dart';
import 'View/Screens/settings/privacy.dart';
import 'View/Screens/settings/term_condation.dart';
import 'View/Screens/settings/ads_with_us.dart';
import 'View/Screens/settings/language_view.dart';
import 'View/Screens/settings/night_mode.dart';
import 'View/Screens/settings/my_account_view.dart';
import 'generated/l10n.dart';

import 'package:live_chat/core/di/service_locator.dart';
import 'package:live_chat/core/helper/cache_helper.dart';
import 'package:live_chat/core/network/network_cubit.dart';
import 'package:live_chat/core/theme/theme_cubit.dart';
import 'package:live_chat/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:live_chat/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:live_chat/features/friends/presentation/cubit/friends_cubit.dart';
import 'package:live_chat/features/home/presentation/cubit/home_cubit.dart';
import 'package:live_chat/features/market/presentation/cubit/market_cubit.dart';
import 'package:live_chat/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:live_chat/features/settings/presentation/cubit/settings_cubit.dart';

SharedPreferences? sharedPreferences;
bool? pref;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sharedPreferences = await SharedPreferences.getInstance();
  CacheHelper.sharedPreferences = sharedPreferences!;

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

    if (!kIsWeb) {
      final firebaseNotification = FirebaseNotification();
      await firebaseNotification.firebasemessaginsetting();
      await firebaseNotification.intilizeNotification();
    }
  } catch (e) {
    debugPrint("Firebase init note: $e");
  }

  sharedPreferences!.getBool("isDarkMode") ??
      await sharedPreferences!.setBool("isDarkMode", false);
  pref = sharedPreferences!.getBool("isDarkMode")!;

  final String initialLocale =
      sharedPreferences!.getString("selectedLanguage") ?? 'ar';
  await sharedPreferences!.setString("selectedLanguage", initialLocale);

  // 1. Initialize Clean Architecture Services & Cubits from lib2
  await initServiceLocator();

  // 2. Legacy bindings for existing UI Views
  Get.put(Api());
  Get.put(AppSettingsController());
  Get.put(NetworkController(), permanent: true);

  runApp(MyApp(initialLocale: initialLocale));
}

class MyApp extends StatelessWidget {
  final String initialLocale;
  const MyApp({super.key, required this.initialLocale});

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
        builder: (context, deviceInfo) => GetBuilder<AppSettingsController>(
          init: AppSettingsController(),
          builder: (controller) => GetMaterialApp(
            onInit: () {
              DynamicLinkService.initDynamicLinks();
            },
            initialBinding: InitialBindings(),
            initialRoute: '/',
            getPages: [
              GetPage(name: '/', page: () => const SplashScreen()),
              GetPage(name: '/PageStart', page: () => const PageStart()),
              GetPage(name: '/home', page: () => const HomeView()),
              GetPage(name: '/auth', page: () => const AuthView()),
              GetPage(name: '/create-chat', page: () => CreateChat()),
              GetPage(name: '/friends', page: () => Friends()),
              GetPage(name: '/requests', page: () => Requests()),
              GetPage(name: '/suggested-friends', page: () => SuggessionChat()),
              GetPage(name: '/notifications', page: () => Notifications()),
              GetPage(name: '/market', page: () => const MarketPage()),
              GetPage(name: '/settings', page: () => const SettingView()),
              GetPage(name: '/privacy', page: () => const Privacy()),
              GetPage(name: '/terms', page: () => const TermCondation()),
              GetPage(name: '/ads-with-us', page: () => const AdsWithUs()),
              GetPage(name: '/language', page: () => LanguageView()),
              GetPage(name: '/night-mode', page: () => NightModeView()),
              GetPage(name: '/my-account', page: () => MyAccountView()),
            ],
            locale: Locale(controller.selectedLanguage.value),
            fallbackLocale: const Locale('ar'),
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
            home: const SplashScreen(),
          ),
        ),
      ),
    );
  }
}
