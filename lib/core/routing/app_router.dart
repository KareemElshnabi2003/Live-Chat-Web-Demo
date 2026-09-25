import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:live_chat/features/auth/presentation/screens/splash_screen.dart';
import 'package:live_chat/features/auth/presentation/screens/page_start_screen.dart';
import 'package:live_chat/features/auth/presentation/screens/auth_screen.dart';
import 'package:live_chat/features/home/presentation/screens/home_screen.dart';
import 'package:live_chat/features/chat/presentation/screens/chat_screen.dart';
import 'package:live_chat/features/chat/presentation/screens/create_chat_screen.dart';
import 'package:live_chat/features/friends/presentation/screens/friends_screen.dart';
import 'package:live_chat/features/friends/presentation/screens/requests_screen.dart';
import 'package:live_chat/features/friends/presentation/screens/suggested_friends_screen.dart';
import 'package:live_chat/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:live_chat/features/market/presentation/screens/market_screen.dart';
import 'package:live_chat/features/settings/presentation/screens/settings_screen.dart';
import 'package:live_chat/features/settings/presentation/screens/privacy_screen.dart';
import 'package:live_chat/features/settings/presentation/screens/term_condition_screen.dart';
import 'package:live_chat/features/settings/presentation/screens/ads_with_us_screen.dart';
import 'package:live_chat/features/settings/presentation/screens/language_screen.dart';
import 'package:live_chat/features/settings/presentation/screens/night_mode_screen.dart';
import 'package:live_chat/features/settings/presentation/screens/my_account_screen.dart';
import 'package:live_chat/features/settings/presentation/screens/capabilities_screen.dart';
import 'package:live_chat/features/chat/presentation/screens/shared_chats_screen.dart';

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
          path: Routes.authScreen,
          builder: (context, state) => const AuthScreen(),
        ),
        GoRoute(
          path: Routes.homeScreen,
          builder: (context, state) => const HomeView(),
        ),
        GoRoute(
          path: Routes.chatScreen,
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return ChatView(
              userChatModel: extra?['userChatModel'],
              isPin: extra?['isPin'] ?? false,
              isGust: extra?['isGust'] ?? false,
            );
          },
        ),
        GoRoute(
          path: Routes.createChatScreen,
          builder: (context, state) => const CreateChat(),
        ),
        GoRoute(
          path: Routes.friendsScreen,
          builder: (context, state) => const Friends(),
        ),
        GoRoute(
          path: Routes.friendRequestsScreen,
          builder: (context, state) => const Requests(),
        ),
        GoRoute(
          path: Routes.suggestedFriendsScreen,
          builder: (context, state) => const SuggessionChat(),
        ),
        GoRoute(
          path: Routes.notificationsScreen,
          builder: (context, state) => const Notifications(),
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
          builder: (context, state) => const LanguageView(),
        ),
        GoRoute(
          path: Routes.nightModeScreen,
          builder: (context, state) => const NightModeView(),
        ),
        GoRoute(
          path: Routes.myAccountScreen,
          builder: (context, state) => const MyAccountView(),
        ),
        GoRoute(
          path: Routes.capabilitiesScreen,
          builder: (context, state) => const Capabilities(),
        ),
        GoRoute(
          path: Routes.sharedChatsScreen,
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return SharedChatsScreen(
              title: extra?['title'] ?? '',
              chatType: extra?['type'] ?? 'recent',
            );
          },
        ),
      ],
    );
  }
}