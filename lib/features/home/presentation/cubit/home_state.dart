abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<dynamic> ads;
  final dynamic pinnedChat;
  final List<dynamic> systemChats;
  final List<dynamic> recentChats;
  final List<dynamic> userChats;
  final int selectedNavIndex;

  HomeLoaded({
    this.ads = const [],
    this.pinnedChat,
    this.systemChats = const [],
    this.recentChats = const [],
    this.userChats = const [],
    this.selectedNavIndex = 0,
  });

  HomeLoaded copyWith({
    List<dynamic>? ads,
    dynamic pinnedChat,
    List<dynamic>? systemChats,
    List<dynamic>? recentChats,
    List<dynamic>? userChats,
    int? selectedNavIndex,
  }) {
    return HomeLoaded(
      ads: ads ?? this.ads,
      pinnedChat: pinnedChat ?? this.pinnedChat,
      systemChats: systemChats ?? this.systemChats,
      recentChats: recentChats ?? this.recentChats,
      userChats: userChats ?? this.userChats,
      selectedNavIndex: selectedNavIndex ?? this.selectedNavIndex,
    );
  }
}

class HomeError extends HomeState {
  final String message;
  HomeError({required this.message});
}
