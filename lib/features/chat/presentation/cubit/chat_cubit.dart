import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:live_chat/core/services/audio/audio_service.dart';
import 'package:live_chat/core/services/pusher/pusher_service.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository chatRepository;
  final PusherService pusherService;
  final AudioService audioService;

  String? _currentChatId;

  ChatCubit({
    required this.chatRepository,
    required this.pusherService,
    required this.audioService,
  }) : super(ChatInitial());

  Future<void> initChat({required String chatId}) async {
    _currentChatId = chatId;
    emit(ChatLoading());

    // Initialize and subscribe to Pusher
    await pusherService.init(onEvent: _handlePusherEvent);
    await pusherService.subscribe("live-chat-ngoum-$chatId");

    // Load initial messages and radios
    final messagesResult = await chatRepository.getMessages(chatId: chatId, page: 1);
    final radiosResult = await chatRepository.getRadios();

    List<dynamic> messages = [];
    List<dynamic> radios = [];

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
        final decoded = jsonDecode(event.data.toString());
        if (state is ChatLoaded) {
          final current = state as ChatLoaded;
          final updatedMessages = List<dynamic>.from(current.messages);
          updatedMessages.insert(0, decoded);
          emit(current.copyWith(messages: updatedMessages));
        }
      } catch (e) {
        debugPrint("Error parsing pusher message: $e");
      }
    }
  }

  Future<void> loadMoreMessages() async {
    if (state is! ChatLoaded) return;
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
        final updated = List<dynamic>.from(current.messages)..addAll(newMessages);
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

  Future<void> sendMediaMessage({required String messageType, MultipartFile? file}) async {
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

  @override
  Future<void> close() async {
    if (_currentChatId != null) {
      await pusherService.unsubscribe("live-chat-ngoum-$_currentChatId");
    }
    await audioService.stopAudio();
    return super.close();
  }
}
