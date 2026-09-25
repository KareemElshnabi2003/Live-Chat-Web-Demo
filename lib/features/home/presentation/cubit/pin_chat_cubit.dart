import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:live_chat/core/helper/cache_helper.dart';
import 'package:live_chat/features/chat/data/models/user_chat_model.dart';
import 'package:live_chat/features/home/domain/repositories/home_repository.dart';
import 'package:live_chat/features/market/domain/repositories/market_repository.dart';

class PinChatState {
  final List<UserChatModel> userChats;
  final String selectedChatId;
  final String selectedDate;
  final List<Map<String, dynamic>> availableTimeSlots;
  final List<String> selectedTimeSlots;
  final XFile? adImage;
  final bool addAds;
  final String paymentMethod;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;

  const PinChatState({
    this.userChats = const [],
    this.selectedChatId = '',
    this.selectedDate = '',
    this.availableTimeSlots = const [],
    this.selectedTimeSlots = const [],
    this.adImage,
    this.addAds = false,
    this.paymentMethod = '',
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
  });

  PinChatState copyWith({
    List<UserChatModel>? userChats,
    String? selectedChatId,
    String? selectedDate,
    List<Map<String, dynamic>>? availableTimeSlots,
    List<String>? selectedTimeSlots,
    XFile? adImage,
    bool clearAdImage = false,
    bool? addAds,
    String? paymentMethod,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    String? successMessage,
  }) {
    return PinChatState(
      userChats: userChats ?? this.userChats,
      selectedChatId: selectedChatId ?? this.selectedChatId,
      selectedDate: selectedDate ?? this.selectedDate,
      availableTimeSlots: availableTimeSlots ?? this.availableTimeSlots,
      selectedTimeSlots: selectedTimeSlots ?? this.selectedTimeSlots,
      adImage: clearAdImage ? null : (adImage ?? this.adImage),
      addAds: addAds ?? this.addAds,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class PinChatCubit extends Cubit<PinChatState> {
  final HomeRepository homeRepository;
  final MarketRepository marketRepository;

  PinChatCubit({
    required this.homeRepository,
    required this.marketRepository,
  }) : super(const PinChatState());

  Future<void> loadUserChats() async {
    emit(state.copyWith(isLoading: true));
    final currentUserId = CacheHelper.getString(key: 'id') ?? '';
    final result = await homeRepository.getUserChats(page: 1, perPage: 30);
    result.fold(
      (error) => emit(state.copyWith(isLoading: false, errorMessage: error)),
      (chats) {
        final filtered = chats.where((element) {
          final isOwner = element.user?.id?.toString() == currentUserId;
          final isGroup = element.status == "Public" || element.status == "Private";
          return isOwner && isGroup;
        }).toList();
        emit(state.copyWith(userChats: filtered, isLoading: false));
      },
    );
  }

  void selectChat(String chatId) {
    emit(state.copyWith(selectedChatId: chatId));
  }

  void selectDate(String date) {
    emit(state.copyWith(selectedDate: date, selectedTimeSlots: []));
    loadTimeSlots(date);
  }

  Future<void> loadTimeSlots(String date) async {
    emit(state.copyWith(isLoading: true));
    final result = await marketRepository.getAvailableTimeSlots(date: date);
    result.fold(
      (error) => emit(state.copyWith(isLoading: false, errorMessage: error)),
      (slots) {
        final list = (slots).map((e) => Map<String, dynamic>.from(e as Map)).toList();
        emit(state.copyWith(availableTimeSlots: list, isLoading: false));
      },
    );
  }

  void toggleTimeSlot(String slot) {
    final updated = List<String>.from(state.selectedTimeSlots);
    if (updated.contains(slot)) {
      updated.remove(slot);
    } else {
      updated.add(slot);
    }
    emit(state.copyWith(selectedTimeSlots: updated));
  }

  void setAddAds(bool value) {
    emit(state.copyWith(addAds: value));
  }

  Future<void> pickAdImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (image != null) {
        emit(state.copyWith(adImage: image));
      }
    } catch (_) {}
  }

  void removeAdImage() {
    emit(state.copyWith(clearAdImage: true));
  }

  void setPaymentMethod(String method) {
    emit(state.copyWith(paymentMethod: method));
  }

  Future<bool> pinChat() async {
    if (state.selectedChatId.isEmpty || state.selectedDate.isEmpty || state.selectedTimeSlots.isEmpty) {
      return false;
    }

    emit(state.copyWith(isSubmitting: true));
    final result = await marketRepository.pinChat(
      conversationId: state.selectedChatId,
      date: state.selectedDate,
      timeSlots: state.selectedTimeSlots,
    );

    return result.fold(
      (error) {
        emit(state.copyWith(isSubmitting: false, errorMessage: error));
        return false;
      },
      (data) {
        emit(state.copyWith(isSubmitting: false, successMessage: "تم تثبيت المحادثة بنجاح"));
        return true;
      },
    );
  }
}
