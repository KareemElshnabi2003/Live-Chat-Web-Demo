import 'package:live_chat/features/chat/data/models/user_chat_model.dart';
import '../../data/models/ads_model.dart';
import '../../data/models/pin_chat_model.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<AdsModel> ads;
  final PinChatModel? pinnedChat;
  final List<UserChatModel> systemChats;
  final List<UserChatModel> recentChats;
  final List<UserChatModel> userChats;
  final int selectedNavIndex;
  final UserChatModel? selectedChat;
  final bool isSelectedChatPin;
  final bool isSelectedChatGust;

  HomeLoaded({
    this.ads = const [],
    this.pinnedChat,
    this.systemChats = const [],
    this.recentChats = const [],
    this.userChats = const [],
    this.selectedNavIndex = 0,
    this.selectedChat,
    this.isSelectedChatPin = false,
    this.isSelectedChatGust = false,
  });

  HomeLoaded copyWith({
    List<AdsModel>? ads,
    PinChatModel? pinnedChat,
    List<UserChatModel>? systemChats,
    List<UserChatModel>? recentChats,
    List<UserChatModel>? userChats,
    int? selectedNavIndex,
    UserChatModel? selectedChat,
    bool? isSelectedChatPin,
    bool? isSelectedChatGust,
    bool clearSelectedChat = false,
  }) {
    return HomeLoaded(
      ads: ads ?? this.ads,
      pinnedChat: pinnedChat ?? this.pinnedChat,
      systemChats: systemChats ?? this.systemChats,
      recentChats: recentChats ?? this.recentChats,
      userChats: userChats ?? this.userChats,
      selectedNavIndex: selectedNavIndex ?? this.selectedNavIndex,
      selectedChat: clearSelectedChat ? null : (selectedChat ?? this.selectedChat),
      isSelectedChatPin: isSelectedChatPin ?? this.isSelectedChatPin,
      isSelectedChatGust: isSelectedChatGust ?? this.isSelectedChatGust,
    );
  }
}

class HomeError extends HomeState {
  final String message;
  HomeError({required this.message});
}
