abstract class FriendsState {}

class FriendsInitial extends FriendsState {}

class FriendsLoading extends FriendsState {}

class FriendsLoaded extends FriendsState {
  final List<dynamic> friends;
  final List<dynamic> suggestedFriends;

  FriendsLoaded({
    this.friends = const [],
    this.suggestedFriends = const [],
  });

  FriendsLoaded copyWith({
    List<dynamic>? friends,
    List<dynamic>? suggestedFriends,
  }) {
    return FriendsLoaded(
      friends: friends ?? this.friends,
      suggestedFriends: suggestedFriends ?? this.suggestedFriends,
    );
  }
}

class FriendsActionSuccess extends FriendsState {
  final String message;
  FriendsActionSuccess({required this.message});
}

class FriendsError extends FriendsState {
  final String message;
  FriendsError({required this.message});
}
