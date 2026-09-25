import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:live_chat/core/constant/app_constant.dart';
import 'package:live_chat/core/helper/cache_helper.dart';
import 'package:live_chat/core/services/audio/audio_service.dart';
import 'package:live_chat/core/services/pusher/pusher_service.dart';
import '../../domain/entities/chat_attachment.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/entities/member_entity.dart';
import '../../domain/entities/radio_entity.dart';
import '../../domain/entities/chat_theme_entity.dart';
import '../../data/models/chat_message_model.dart';
import '../../domain/usecases/chat_use_cases.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final GetMessagesUseCase getMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final SendMessageWithFileUseCase sendMessageWithFileUseCase;
  final SendReactionUseCase sendReactionUseCase;
  final GetMembersUseCase getMembersUseCase;
  final GetRadiosUseCase getRadiosUseCase;
  final GetThemesUseCase getThemesUseCase;
  final CreateGeneralChatUseCase createGeneralChatUseCase;
  final UpdateGeneralChatUseCase updateGeneralChatUseCase;
  final DeleteChatUseCase deleteChatUseCase;
  final AcceptMemberToChatUseCase acceptMemberToChatUseCase;
  final BlockOrUnBlockUseCase blockOrUnBlockUseCase;
  final CreateChatFriendUseCase createChatFriendUseCase;
  final PusherService pusherService;
  final AudioService audioService;

  String? _currentChatId;
  StreamSubscription<PusherEvent>? _pusherSub;
  final Set<String> _messageIdSet = {};

  ChatCubit({
    required this.getMessagesUseCase,
    required this.sendMessageUseCase,
    required this.sendMessageWithFileUseCase,
    required this.sendReactionUseCase,
    required this.getMembersUseCase,
    required this.getRadiosUseCase,
    required this.getThemesUseCase,
    required this.createGeneralChatUseCase,
    required this.updateGeneralChatUseCase,
    required this.deleteChatUseCase,
    required this.acceptMemberToChatUseCase,
    required this.blockOrUnBlockUseCase,
    required this.createChatFriendUseCase,
    required this.pusherService,
    required this.audioService,
  }) : super(ChatInitial());

  Future<void> initChat({required String chatId}) async {
    _currentChatId = chatId;
    _messageIdSet.clear();
    emit(ChatLoading());

    // 1. Clean up any previous Pusher subscription and listeners
    await _pusherSub?.cancel();
    _pusherSub = null;

    // 2. Initialize and subscribe to Pusher channel stream
    await pusherService.init();
    final channelName = "live-chat-ngoum-$chatId";
    await pusherService.subscribe(channelName);
    _pusherSub = pusherService.eventStreamForChannel(channelName).listen(_handlePusherEvent);

    // 3. Parallel API fetch for Messages and Radios
    final messagesFuture = getMessagesUseCase(chatId: chatId, page: 1);
    final radiosFuture = getRadiosUseCase();

    final messagesResult = await messagesFuture;
    final radiosResult = await radiosFuture;

    List<ChatMessageEntity> messages = [];
    List<RadioEntity> radios = [];

    messagesResult.fold(
      (failure) => debugPrint("Failed to fetch messages: ${failure.message}"),
      (msgs) {
        messages = msgs;
        for (final m in messages) {
          if (m.messageId.isNotEmpty) {
            _messageIdSet.add(m.messageId);
          }
        }
      },
    );

    radiosResult.fold(
      (failure) => debugPrint("Failed to fetch radios: ${failure.message}"),
      (rads) {
        radios = rads;
      },
    );

    emit(ChatLoaded(
      messages: messages,
      radios: radios,
      currentPage: 1,
      hasMoreMessages: messages.length >= 20,
    ));
  }

  void _handlePusherEvent(PusherEvent event) {
    if (event.eventName == "message-created" &&
        event.channelName == "live-chat-ngoum-$_currentChatId") {
      try {
        final dynamic raw = event.data is String ? jsonDecode(event.data.toString()) : event.data;
        if (raw is Map && state is ChatLoaded) {
          final current = state as ChatLoaded;
          final currentUserId = CacheHelper.getString(key: AppConstants.userIdKey);
          final map = raw is Map<String, dynamic> ? raw : Map<String, dynamic>.from(raw);
          final newMsg = ChatMessageModel.fromJson(map, currentUserId: currentUserId);

          // Fast O(1) deduplication using Set
          if (newMsg.messageId.isNotEmpty) {
            if (_messageIdSet.contains(newMsg.messageId)) {
              return; // Ignore duplicate
            }
            _messageIdSet.add(newMsg.messageId);
          }

          final updatedMessages = List<ChatMessageEntity>.from(current.messages)..insert(0, newMsg);
          emit(current.copyWith(messages: updatedMessages));
        }
      } catch (e) {
        debugPrint("Error parsing pusher message: $e");
      }
    }
  }

  Future<void> loadMoreMessages() async {
    if (state is! ChatLoaded || _currentChatId == null) return;
    final current = state as ChatLoaded;
    if (current.isLoadingMore || !current.hasMoreMessages) return;

    emit(current.copyWith(isLoadingMore: true));

    final nextPage = current.currentPage + 1;
    final result = await getMessagesUseCase(
      chatId: _currentChatId!,
      page: nextPage,
    );

    result.fold(
      (failure) {
        debugPrint("Failed to load more messages: ${failure.message}");
        emit(current.copyWith(isLoadingMore: false));
      },
      (newMessages) {
        final List<ChatMessageEntity> uniqueNew = [];
        for (final m in newMessages) {
          if (m.messageId.isNotEmpty) {
            if (!_messageIdSet.contains(m.messageId)) {
              _messageIdSet.add(m.messageId);
              uniqueNew.add(m);
            }
          } else {
            uniqueNew.add(m);
          }
        }

        final allMessages = List<ChatMessageEntity>.from(current.messages)..addAll(uniqueNew);
        emit(current.copyWith(
          messages: allMessages,
          currentPage: nextPage,
          hasMoreMessages: newMessages.length >= 20,
          isLoadingMore: false,
        ));
      },
    );
  }

  Future<void> sendMessage(String message) async {
    if (_currentChatId == null) return;
    final result = await sendMessageUseCase(chatId: _currentChatId!, message: message);
    result.fold(
      (failure) => debugPrint("Failed to send message: ${failure.message}"),
      (_) {},
    );
  }

  Future<void> sendMediaMessage({
    required String messageType,
    ChatAttachment? file,
  }) async {
    if (_currentChatId == null) return;
    final result = await sendMessageWithFileUseCase(
      chatId: _currentChatId!,
      messageType: messageType,
      file: file,
    );
    result.fold(
      (failure) => debugPrint("Failed to send file: ${failure.message}"),
      (_) {},
    );
  }

  Future<void> sendReaction({required String messageId, required String react}) async {
    final result = await sendReactionUseCase(messageId: messageId, react: react);
    result.fold(
      (failure) => debugPrint("Failed to send reaction: ${failure.message}"),
      (_) {},
    );
  }

  void setReplyingToMessage(ChatMessageEntity message) {
    if (state is ChatLoaded) {
      emit((state as ChatLoaded).copyWith(replyingToMessage: message));
    }
  }

  void cancelReply() {
    if (state is ChatLoaded) {
      emit((state as ChatLoaded).copyWith(clearReply: true));
    }
  }

  Future<void> playRadio(String url) async {
    if (state is! ChatLoaded) return;
    final current = state as ChatLoaded;
    await audioService.playAudioFromUrl(url);
    emit(current.copyWith(isRadioPlaying: true, currentRadioUrl: url));
  }

  Future<void> stopRadio() async {
    if (state is! ChatLoaded) return;
    final current = state as ChatLoaded;
    await audioService.stopAudio();
    emit(current.copyWith(isRadioPlaying: false, currentRadioUrl: null));
  }

  Future<void> toggleRadio(String? url) async {
    if (state is! ChatLoaded) return;
    final current = state as ChatLoaded;

    if (current.isRadioPlaying && current.currentRadioUrl == url) {
      await stopRadio();
    } else if (url != null && url.isNotEmpty) {
      await playRadio(url);
    }
  }

  Future<List<ChatThemeEntity>> getThemes() async {
    final result = await getThemesUseCase();
    return result.fold((l) => [], (r) => r);
  }

  Future<bool> createGeneralChat({
    required Map<String, dynamic> data,
    ChatAttachment? imgChat,
    ChatAttachment? bgChat,
  }) async {
    final result = await createGeneralChatUseCase(
      data: data,
      imgChat: imgChat,
      bgChat: bgChat,
    );
    return result.fold((l) => false, (r) => true);
  }

  Future<bool> updateGeneralChat({
    required String chatId,
    required Map<String, dynamic> data,
    ChatAttachment? imgChat,
    ChatAttachment? bgChat,
  }) async {
    final result = await updateGeneralChatUseCase(
      chatId: chatId,
      data: data,
      imgChat: imgChat,
      bgChat: bgChat,
    );
    return result.fold((l) => false, (r) => true);
  }

  Future<bool> deleteChat({required String chatId}) async {
    final result = await deleteChatUseCase(chatId: chatId);
    return result.fold((l) => false, (r) => true);
  }

  Future<bool> acceptMemberToChat({
    required String chatId,
    required String userId,
  }) async {
    final result = await acceptMemberToChatUseCase(chatId: chatId, userId: userId);
    return result.fold((l) => false, (r) => true);
  }

  Future<bool> blockOrUnBlock({
    required int status,
    required String userId,
  }) async {
    final result = await blockOrUnBlockUseCase(status: status, userId: userId);
    return result.fold((l) => false, (r) => true);
  }

  Future<List<MemberEntity>> getMembers({required String chatId, int page = 1}) async {
    final result = await getMembersUseCase(chatId: chatId, page: page);
    return result.fold((l) => [], (r) => r);
  }

  @override
  Future<void> close() async {
    await _pusherSub?.cancel();
    _pusherSub = null;
    if (_currentChatId != null) {
      await pusherService.unsubscribe("live-chat-ngoum-$_currentChatId");
    }
    _messageIdSet.clear();
    await audioService.stopAudio();
    return super.close();
  }
}
