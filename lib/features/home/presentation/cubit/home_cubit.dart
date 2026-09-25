import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat/features/chat/domain/entities/user_chat_entity.dart';
import '../../domain/entities/ad_entity.dart';
import '../../domain/entities/pin_chat_entity.dart';
import '../../domain/repositories/home_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository homeRepository;

  HomeCubit({required this.homeRepository}) : super(HomeInitial());

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void changeNavIndex(int index) {
    _currentIndex = index;
    if (state is HomeLoaded) {
      emit((state as HomeLoaded).copyWith(
        selectedNavIndex: index,
        clearSelectedChat: true,
      ));
    }
  }

  void selectChat(UserChatEntity? chat, {bool isPin = false, bool isGust = false}) {
    if (state is HomeLoaded) {
      emit((state as HomeLoaded).copyWith(
        selectedChat: chat,
        isSelectedChatPin: isPin,
        isSelectedChatGust: isGust,
      ));
    }
  }

  void clearSelectedChat() {
    if (state is HomeLoaded) {
      emit((state as HomeLoaded).copyWith(clearSelectedChat: true));
    }
  }

  Future<void> loadHomeData() async {
    emit(HomeLoading());
    try {
      final results = await Future.wait([
        homeRepository.getAds(),
        homeRepository.getPinnedChat(),
        homeRepository.getSystemChats(),
        homeRepository.getRecentChats(),
        homeRepository.getUserChats(),
      ]);

      List<AdEntity> ads = [];
      PinChatEntity? pinnedChat;
      List<UserChatEntity> systemChats = [];
      List<UserChatEntity> recentChats = [];
      List<UserChatEntity> userChats = [];

      results[0].fold((_) {}, (r) => ads = r as List<AdEntity>);
      results[1].fold((_) {}, (r) => pinnedChat = r as PinChatEntity?);
      results[2].fold((_) {}, (r) => systemChats = r as List<UserChatEntity>);
      results[3].fold((_) {}, (r) => recentChats = r as List<UserChatEntity>);
      results[4].fold((_) {}, (r) => userChats = r as List<UserChatEntity>);

      emit(HomeLoaded(
        ads: ads,
        pinnedChat: pinnedChat,
        systemChats: systemChats,
        recentChats: recentChats,
        userChats: userChats,
        selectedNavIndex: _currentIndex,
      ));
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  Future<void> refreshHome() async {
    await loadHomeData();
  }

  Future<bool> joinToChat({required dynamic chatId}) async {
    final result = await homeRepository.joinToChat(chatId: chatId.toString());
    return result.fold((error) => false, (success) => success);
  }
}
