import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:live_chat/View/Screens/Home/home_view.dart';
import 'package:live_chat/View/Screens/Market/market_page.dart';
import 'package:live_chat/View/Screens/auth/auth_view.dart';
import 'package:live_chat/View/Screens/create%20chat/create_chat.dart';
import 'package:live_chat/View/Screens/friends/friends.dart';
import 'package:live_chat/View/Screens/friends/requests.dart';
import 'package:live_chat/View/Screens/notifications/notifications.dart';
import 'package:live_chat/View/Screens/settings/ads_with_us.dart';
import 'package:live_chat/View/Screens/settings/language_view.dart';
import 'package:live_chat/View/Screens/settings/my_account_view.dart';
import 'package:live_chat/View/Screens/settings/night_mode.dart';
import 'package:live_chat/View/Screens/settings/privacy.dart';
import 'package:live_chat/View/Screens/settings/setting_view.dart';
import 'package:live_chat/View/Screens/settings/term_condation.dart';
import 'package:live_chat/View/Screens/splash/splash_screen.dart';
import 'package:live_chat/View/Screens/start%20page/page_start.dart';
import 'package:live_chat/View/Screens/suggession%20friends/suggession%20friends.dart';
import 'routes.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static GoRouter? _router;

  static GoRouter getRouter(String initialLocation) {
    return _router ??= _createRouter(initialLocation);
  }

  static GoRouter _createRouter(String initialLocation) {
    return GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: Routes.splashScreen,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: Routes.startPageScreen,
          builder: (context, state) => const PageStart(),
        ),
        GoRoute(
          path: '/auth',
          builder: (context, state) => const AuthView(),
        ),
        GoRoute(
          path: Routes.homeScreen,
          builder: (context, state) => const HomeView(),
        ),
        GoRoute(
          path: Routes.createChatScreen,
          builder: (context, state) => CreateChat(),
        ),
        GoRoute(
          path: Routes.friendsScreen,
          builder: (context, state) => Friends(),
        ),
        GoRoute(
          path: Routes.friendRequestsScreen,
          builder: (context, state) => Requests(),
        ),
        GoRoute(
          path: Routes.suggestedFriendsScreen,
          builder: (context, state) => SuggessionChat(),
        ),
        GoRoute(
          path: Routes.notificationsScreen,
          builder: (context, state) => Notifications(),
        ),
        GoRoute(
          path: Routes.marketScreen,
          builder: (context, state) => const MarketPage(),
        ),
        GoRoute(
          path: Routes.settingsScreen,
          builder: (context, state) => const SettingView(),
        ),
        GoRoute(
          path: Routes.privacyScreen,
          builder: (context, state) => const Privacy(),
        ),
        GoRoute(
          path: Routes.termsScreen,
          builder: (context, state) => const TermCondation(),
        ),
        GoRoute(
          path: Routes.adsWithUsScreen,
          builder: (context, state) => const AdsWithUs(),
        ),
        GoRoute(
          path: Routes.languageScreen,
          builder: (context, state) => LanguageView(),
        ),
        GoRoute(
          path: Routes.nightModeScreen,
          builder: (context, state) => NightModeView(),
        ),
        GoRoute(
          path: Routes.myAccountScreen,
          builder: (context, state) => MyAccountView(),
        ),
      ],
    );
  }
}