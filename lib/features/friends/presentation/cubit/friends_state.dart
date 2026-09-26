import '../../domain/entities/friend_suggest_entity.dart';

abstract class FriendsState {}

class FriendsInitial extends FriendsState {}

class FriendsLoading extends FriendsState {}

class FriendsLoaded extends FriendsState {
  final List<FriendSuggestEntity> friends;
  final List<FriendSuggestEntity> suggestedFriends;
  final List<FriendSuggestEntity> receivedRequests;
  final List<FriendSuggestEntity> sentRequests;
  final bool isEditing;

  FriendsLoaded({
    this.friends = const [],
    this.suggestedFriends = const [],
    this.receivedRequests = const [],
    this.sentRequests = const [],
    this.isEditing = false,
  });

  int get pendingRequestsCount => receivedRequests.length + sentRequests.length;

  FriendsLoaded copyWith({
    List<FriendSuggestEntity>? friends,
    List<FriendSuggestEntity>? suggestedFriends,
    List<FriendSuggestEntity>? receivedRequests,
    List<FriendSuggestEntity>? sentRequests,
    bool? isEditing,
  }) {
    return FriendsLoaded(
      friends: friends ?? this.friends,
      suggestedFriends: suggestedFriends ?? this.suggestedFriends,
      receivedRequests: receivedRequests ?? this.receivedRequests,
      sentRequests: sentRequests ?? this.sentRequests,
      isEditing: isEditing ?? this.isEditing,
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
