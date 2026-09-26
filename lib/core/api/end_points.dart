import 'package:flutter/foundation.dart';

class EndPoints {
  static const String baseUrl = kIsWeb
      ? "https://live-chat-web-demo.kelsayed2012003.workers.dev/api/v1"
      : "https://api.mayo.live/api/v1";

  // Ads & Pages
  static const String getAds = "$baseUrl/admin_ads";
  static const String privacyPolicy = "$baseUrl/pages/privacy-policy";
  static const String terms = "$baseUrl/pages/terms-conditions";
  static const String adsWithUs = "$baseUrl/pages/admin-ads";
  static const String pinChat = "$baseUrl/pinned-conversations";
  static const String checkCallUrl = "$baseUrl/status";
  static const String endCallUrl = "$baseUrl/end";
  static const String blockUrl = "$baseUrl/users";
  static const String getTokenCallUrl = "$baseUrl/generate-token";
  static const String changeThemeUrl = "$baseUrl/auth/change-mobile-theme";
  static const String getRadiosUrl = "$baseUrl/radios";
  static const String sendStars = "$baseUrl/send-stars";

  // Auth
  static const String loginUrl = "$baseUrl/auth/login";
  static const String registerUrl = "$baseUrl/auth/register";
  static const String checkOTPUrl = "$baseUrl/auth/check-otp";
  static const String sendOTPUrl = "$baseUrl/auth/send-otp";
  static const String resendOTPUrl = "$baseUrl/auth/resend-otp";
  static const String logoutUrl = "$baseUrl/auth/logout";
  static const String guestUrl = "$baseUrl/auth/verify-guest-user";

  // Profile
  static const String deleteAccUrl = "$baseUrl/auth/delete-account";
  static const String getProfileUrl = "$baseUrl/auth/get-profile";
  static const String updateProfileUrl = "$baseUrl/auth/update-profile";
  static const String getUserPower = "$baseUrl/user_powers";
  static const String storePower = "$baseUrl/store-powers";
  static const String stores = "$baseUrl/stores";

  // Friends & Requests
  static const String sendFriendRequestUrl = "$baseUrl/send-friend-request";
  static const String removeFriendUrl = "$baseUrl/remove-friend";
  static const String acceptOrRejectFriendUrl = "$baseUrl/reply-on-friend";
  static const String acceptMemberToChat = "$baseUrl/accept-members";
  static const String getSuggestFriendsUrl = "$baseUrl/get-friend-recommendations";
  static const String getFriendsUrl = "$baseUrl/get-user-friends";

  // Notifications
  static const String getNotificationUrl = "$baseUrl/get-user-notifications";

  // Conversations & Chat
  static const String conversations = "$baseUrl/conversations";
  static const String createChatFriendUrl = "$baseUrl/conversations-friend";
  static const String getMemberChatUrl = "$baseUrl/get-conversation-members";
  static const String getGeneralChatsUrl = "$baseUrl/get-general-conversation";
  static const String getRecentChatsUrl = "$baseUrl/get-recent-conversations";
  static const String getSystemChatUrl = "$baseUrl/get-system-conversations";
  static const String getUsersChatUrl = "$baseUrl/get-user-conversations";
  static const String joinChatUrl = "$baseUrl/join-to-conversation";
  static const String getMessagesChatUrl = "$baseUrl/get-messages-by-conversation-id";
  static const String sendMessagesUrl = "$baseUrl/messages";
  static const String reactToMessageUrl = "$baseUrl/message-reactions";
  static const String getThemesUrl = "$baseUrl/chat-themes";
  static const String getAvailableTime = "$baseUrl/available-time-slots";

  // Payment
  static const String manualPaymentOptions = "$baseUrl/manual_payment_orders/payment_options";
  static const String manualPaymentData = "$baseUrl/manual_payment_data";
  static const String manualPaymentOrders = "$baseUrl/manual_payment_orders";
}

class ApiKey {
  static const String status = 'status';
  static const String message = 'message';
  static const String errorMessage = 'message';
  static const String msg = 'msg';
  static const String error = 'error';
  static const String token = 'token';
  static const String data = 'data';
}
