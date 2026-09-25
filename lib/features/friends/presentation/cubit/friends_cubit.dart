import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat/core/di/service_locator.dart';
import 'package:live_chat/features/chat/data/models/user_chat_model.dart';
import 'package:live_chat/features/chat/domain/repositories/chat_repository.dart';
import '../../data/models/friend_suggest_model.dart';
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

    List<SuggestFreindModel> allItems = [];
    List<SuggestFreindModel> suggestions = [];

    results[0].fold((_) {}, (r) => allItems = r);
    results[1].fold((_) {}, (r) => suggestions = r);

    final friends = allItems.where((e) => e.requestStatus == "friends").toList();
    final received = allItems.where((e) => e.requestStatus == "request_received").toList();
    final sent = allItems.where((e) => e.requestStatus == "request_sent").toList();

    emit(FriendsLoaded(
      friends: friends,
      suggestedFriends: suggestions,
      receivedRequests: received,
      sentRequests: sent,
      isEditing: false,
    ));
  }

  void toggleEditing() {
    if (state is FriendsLoaded) {
      final current = state as FriendsLoaded;
      emit(current.copyWith(isEditing: !current.isEditing));
    }
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

  Future<void> loadFriends() => loadFriendsAndSuggestions();

  Future<void> sendFriendRequest({required int friendId}) =>
      sendRequest(friendId.toString());

  Future<UserChatModel?> createChatFriend({required int friendId}) async {
    final result =
        await sl<ChatRepository>().createChatFriend(friendId: friendId);
    return result.fold(
      (error) {
        emit(FriendsError(message: error));
        return null;
      },
      (data) {
        if (data is Map && data['data'] != null) {
          return UserChatModel.fromJson(data['data']);
        }
        return null;
      },
    );
  }
}
