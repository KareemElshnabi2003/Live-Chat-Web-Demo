import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/friends_repository.dart';
import 'friends_state.dart';

class FriendsCubit extends Cubit<FriendsState> {
  final FriendsRepository friendsRepository;

  FriendsCubit({required this.friendsRepository}) : super(FriendsInitial());

  Future<void> loadFriendsAndSuggestions() async {
    emit(FriendsLoading());
    final results = await Future.wait([
      friendsRepository.getFriends(),
      friendsRepository.getSuggestedFriends(),
    ]);

    List<dynamic> friends = [];
    List<dynamic> suggestions = [];

    results[0].fold((_) {}, (r) => friends = r);
    results[1].fold((_) {}, (r) => suggestions = r);

    emit(FriendsLoaded(
      friends: friends,
      suggestedFriends: suggestions,
    ));
  }

  Future<void> sendRequest(String friendId) async {
    final result = await friendsRepository.sendFriendRequest(friendId: friendId);
    result.fold(
      (error) => emit(FriendsError(message: error)),
      (_) {
        emit(FriendsActionSuccess(message: "تم إرسال الطلب بنجاح"));
        loadFriendsAndSuggestions();
      },
    );
  }

  Future<void> replyFriendRequest(String friendId, String status) async {
    final result = await friendsRepository.acceptOrRejectFriend(
      friendId: friendId,
      status: status,
    );
    result.fold(
      (error) => emit(FriendsError(message: error)),
      (_) {
        emit(FriendsActionSuccess(message: status == "accept" ? "تم قبول الصداقة" : "تم رفض الطلب"));
        loadFriendsAndSuggestions();
      },
    );
  }

  Future<void> deleteFriend(String friendId) async {
    final result = await friendsRepository.removeFriend(friendId: friendId);
    result.fold(
      (error) => emit(FriendsError(message: error)),
      (_) {
        emit(FriendsActionSuccess(message: "تم حذف الصديق"));
        loadFriendsAndSuggestions();
      },
    );
  }
}
