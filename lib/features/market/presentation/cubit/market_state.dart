abstract class MarketState {}

class MarketInitial extends MarketState {}

class MarketLoading extends MarketState {}

class MarketLoaded extends MarketState {
  final Map<String, dynamic> userProfile;
  final List<dynamic> storePowers;
  final List<dynamic> userPowers;
  final int numOfStars;
  final bool hasMore;
  final int currentPage;

  MarketLoaded({
    required this.userProfile,
    required this.storePowers,
    this.userPowers = const [],
    required this.numOfStars,
    this.hasMore = true,
    this.currentPage = 1,
  });

  MarketLoaded copyWith({
    Map<String, dynamic>? userProfile,
    List<dynamic>? storePowers,
    List<dynamic>? userPowers,
    int? numOfStars,
    bool? hasMore,
    int? currentPage,
  }) {
    return MarketLoaded(
      userProfile: userProfile ?? this.userProfile,
      storePowers: storePowers ?? this.storePowers,
      userPowers: userPowers ?? this.userPowers,
      numOfStars: numOfStars ?? this.numOfStars,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class MarketError extends MarketState {
  final String message;

  MarketError({required this.message});
}

class PaymentLoading extends MarketState {}

class PaymentSuccess extends MarketState {
  final dynamic data;
  PaymentSuccess({required this.data});
}

class PaymentError extends MarketState {
  final String message;
  PaymentError({required this.message});
}
