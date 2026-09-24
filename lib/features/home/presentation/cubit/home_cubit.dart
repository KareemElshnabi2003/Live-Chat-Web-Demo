import 'package:flutter_bloc/flutter_bloc.dart';
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
      emit((state as HomeLoaded).copyWith(selectedNavIndex: index));
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

      List<dynamic> ads = [];
      dynamic pinnedChat;
      List<dynamic> systemChats = [];
      List<dynamic> recentChats = [];
      List<dynamic> userChats = [];

      results[0].fold((_) {}, (r) => ads = r as List<dynamic>);
      results[1].fold((_) {}, (r) => pinnedChat = r);
      results[2].fold((_) {}, (r) => systemChats = r as List<dynamic>);
      results[3].fold((_) {}, (r) => recentChats = r as List<dynamic>);
      results[4].fold((_) {}, (r) => userChats = r as List<dynamic>);

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
}
