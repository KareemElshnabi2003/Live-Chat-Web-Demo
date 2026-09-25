import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:live_chat/core/constant/app_constant.dart';
import 'package:live_chat/core/helper/cache_helper.dart';
import 'package:live_chat/core/services/audio/audio_service.dart';
import 'package:live_chat/core/services/pusher/pusher_service.dart';
import 'package:live_chat/features/chat/data/models/chat_message_model.dart';
import 'package:live_chat/features/chat/data/models/member_of_chat_model.dart';
import 'package:live_chat/features/home/data/models/radio_model.dart';
import '../../domain/entities/chat_attachment.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository chatRepository;
  final PusherService pusherService;
  final AudioService audioService;

  String? _currentChatId;
  StreamSubscription<PusherEvent>? _pusherSub;

  ChatCubit({
    required this.chatRepository,
    required this.pusherService,
    required this.audioService,
  }) : super(ChatInitial());

  Future<void> initChat({required String chatId}) async {
    _currentChatId = chatId;
    emit(ChatLoading());

    // Clean up any previous Pusher subscription
    await _pusherSub?.cancel();
    _pusherSub = null;

    // Initialize and subscribe to Pusher channel stream
    await pusherService.init();
    final channelName = "live-chat-ngoum-$chatId";
    await pusherService.subscribe(channelName);
    _pusherSub = pusherService.eventStreamForChannel(channelName).listen(_handlePusherEvent);

    // Load initial messages and radios
    final messagesResult = await chatRepository.getMessages(chatId: chatId, page: 1);
    final radiosResult = await chatRepository.getRadios();

    List<ChatMessage> messages = [];
    List<RadioModel> radios = [];

    messagesResult.fold((_) {}, (r) => messages = r);
    radiosResult.fold((_) {}, (r) => radios = r);

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
          final newMsg = ChatMessage.fromJson(map, currentUserId: currentUserId);

          // Deduplication: prevent duplicate messages from entering the list
          final isDuplicate = current.messages.any(
            (m) => m.messageId == newMsg.messageId && newMsg.messageId.isNotEmpty,
          );

          if (!isDuplicate) {
            final updatedMessages = List<ChatMessage>.from(current.messages)..insert(0, newMsg);
            emit(current.copyWith(messages: updatedMessages));
          }
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
    final result = await chatRepository.getMessages(
      chatId: _currentChatId!,
      page: nextPage,
    );

    result.fold(
      (error) => emit(current.copyWith(isLoadingMore: false)),
      (newMessages) {
        // Deduplicate incoming paged messages against current list
        final existingIds = current.messages.map((m) => m.messageId).toSet();
        final uniqueNew = newMessages.where((m) => !existingIds.contains(m.messageId)).toList();
        final updated = List<ChatMessage>.from(current.messages)..addAll(uniqueNew);

        emit(current.copyWith(
          messages: updated,
          currentPage: nextPage,
          isLoadingMore: false,
          hasMoreMessages: newMessages.length >= 20,
        ));
      },
    );
  }

  Future<void> sendMessage(String text) async {
    if (_currentChatId == null || text.trim().isEmpty) return;
    await chatRepository.sendMessage(chatId: _currentChatId!, message: text.trim());
  }

  Future<void> sendMediaMessage({required String messageType, ChatAttachment? file}) async {
    if (_currentChatId == null) return;
    await chatRepository.sendMessageWithFile(
      chatId: _currentChatId!,
      messageType: messageType,
      file: file,
    );
  }

  Future<void> sendReaction({required String messageId, required String react}) async {
    await chatRepository.sendReaction(messageId: messageId, react: react);
  }

  void setReplyingToMessage(ChatMessage? message) {
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
    try {
      await audioService.playAudioFromUrl(url);
      emit(current.copyWith(isRadioPlaying: true, currentRadioUrl: url));
    } catch (e) {
      debugPrint("Radio error: $e");
    }
  }

  Future<void> stopRadio() async {
    if (state is! ChatLoaded) return;
    final current = state as ChatLoaded;
    await audioService.stopAudio();
    emit(current.copyWith(isRadioPlaying: false, currentRadioUrl: null));
  }

  Future<List<dynamic>> getThemes() async {
    final result = await chatRepository.getThemes();
    return result.fold((l) => [], (r) => r);
  }

  Future<bool> createGeneralChat({
    required Map<String, dynamic> data,
    ChatAttachment? imgChat,
    ChatAttachment? bgChat,
  }) async {
    final result = await chatRepository.createGeneralChat(
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
    final result = await chatRepository.updateGeneralChat(
      chatId: chatId,
      data: data,
      imgChat: imgChat,
      bgChat: bgChat,
    );
    return result.fold((l) => false, (r) => true);
  }

  Future<bool> deleteChat({required String chatId}) async {
    final result = await chatRepository.deleteChat(chatId: chatId);
    return result.fold((l) => false, (r) => true);
  }

  Future<bool> acceptMemberToChat({
    required String chatId,
    required String userId,
  }) async {
    final result = await chatRepository.acceptMemberToChat(chatId: chatId, userId: userId);
    return result.fold((l) => false, (r) => true);
  }

  Future<bool> blockOrUnBlock({
    required int status,
    required String userId,
  }) async {
    final result = await chatRepository.blockOrUnBlock(status: status, userId: userId);
    return result.fold((l) => false, (r) => true);
  }

  Future<List<MemberOfChatModel>> getMembers({required String chatId, int page = 1}) async {
    final result = await chatRepository.getMembers(chatId: chatId, page: page);
    return result.fold((l) => [], (r) => r);
  }

  @override
  Future<void> close() async {
    await _pusherSub?.cancel();
    _pusherSub = null;
    if (_currentChatId != null) {
      await pusherService.unsubscribe("live-chat-ngoum-$_currentChatId");
    }
    await audioService.stopAudio();
    return super.close();
  }
}
