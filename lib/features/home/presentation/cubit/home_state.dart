import 'package:live_chat/features/chat/domain/entities/user_chat_entity.dart';
import '../../domain/entities/ad_entity.dart';
import '../../domain/entities/pin_chat_entity.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<AdEntity> ads;
  final PinChatEntity? pinnedChat;
  final List<UserChatEntity> systemChats;
  final List<UserChatEntity> recentChats;
  final List<UserChatEntity> userChats;
  final int selectedNavIndex;
  final UserChatEntity? selectedChat;
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
    List<AdEntity>? ads,
    PinChatEntity? pinnedChat,
    List<UserChatEntity>? systemChats,
    List<UserChatEntity>? recentChats,
    List<UserChatEntity>? userChats,
    int? selectedNavIndex,
    UserChatEntity? selectedChat,
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

