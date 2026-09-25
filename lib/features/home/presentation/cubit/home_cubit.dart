import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat/features/chat/data/models/user_chat_model.dart';
import '../../data/models/ads_model.dart';
import '../../data/models/pin_chat_model.dart';
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

  void selectChat(UserChatModel? chat, {bool isPin = false, bool isGust = false}) {
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

      List<AdsModel> ads = [];
      PinChatModel? pinnedChat;
      List<UserChatModel> systemChats = [];
      List<UserChatModel> recentChats = [];
      List<UserChatModel> userChats = [];

      results[0].fold((_) {}, (r) => ads = r as List<AdsModel>);
      results[1].fold((_) {}, (r) => pinnedChat = r as PinChatModel?);
      results[2].fold((_) {}, (r) => systemChats = r as List<UserChatModel>);
      results[3].fold((_) {}, (r) => recentChats = r as List<UserChatModel>);
      results[4].fold((_) {}, (r) => userChats = r as List<UserChatModel>);

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
    final result = await homeRepository.joinToChat(chatId: chatId);
    return result.fold((error) => false, (success) => success);
  }
}
