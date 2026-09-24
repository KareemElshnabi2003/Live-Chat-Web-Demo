import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/market_repository.dart';
import 'market_state.dart';

class MarketCubit extends Cubit<MarketState> {
  final MarketRepository marketRepository;

  MarketCubit({required this.marketRepository}) : super(MarketInitial());

  int _currentPage = 1;
  final int _perPage = 20;
  bool _hasMore = true;
  List<dynamic> _storePowers = [];
  Map<String, dynamic> _userProfile = {};
  int _numOfStars = 0;

  Future<void> loadMarketData({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      _hasMore = true;
      _storePowers = [];
    }

    if (_currentPage == 1) {
      emit(MarketLoading());
    }

    final profileResult = await marketRepository.getProfile();
    profileResult.fold(
      (error) => null,
      (profile) {
        _userProfile = profile;
        _numOfStars = profile['number_of_stars'] ?? 0;
      },
    );

    final powersResult = await marketRepository.getStorePowers(
      page: _currentPage,
      perPage: _perPage,
    );

    powersResult.fold(
      (error) {
        if (_currentPage == 1) {
          emit(MarketError(message: error));
        }
      },
      (powers) {
        if (powers.length < _perPage) {
          _hasMore = false;
        }
        if (isRefresh || _currentPage == 1) {
          _storePowers = powers;
        } else {
          _storePowers.addAll(powers);
        }
        emit(MarketLoaded(
          userProfile: _userProfile,
          storePowers: _storePowers,
          numOfStars: _numOfStars,
          hasMore: _hasMore,
          currentPage: _currentPage,
        ));
      },
    );
  }

  Future<void> loadMorePowers() async {
    if (!_hasMore || state is MarketLoading) return;
    _currentPage++;
    final powersResult = await marketRepository.getStorePowers(
      page: _currentPage,
      perPage: _perPage,
    );

    powersResult.fold(
      (error) => _currentPage--,
      (powers) {
        if (powers.length < _perPage) {
          _hasMore = false;
        }
        _storePowers.addAll(powers);
        emit(MarketLoaded(
          userProfile: _userProfile,
          storePowers: _storePowers,
          numOfStars: _numOfStars,
          hasMore: _hasMore,
          currentPage: _currentPage,
        ));
      },
    );
  }

  Future<void> togglePower({
    required String powerId,
    required String status,
  }) async {
    final result = await marketRepository.closePower(
      powerId: powerId,
      status: status,
    );
    result.fold(
      (error) => null,
      (_) => loadMarketData(isRefresh: true),
    );
  }

  Future<void> submitManualPayment({
    required List<int> imageBytes,
    required String imageName,
    required int price,
    required String paymentAddress,
    required String paymentType,
    required int stars,
  }) async {
    emit(PaymentLoading());
    final result = await marketRepository.submitManualPayment(
      imageBytes: imageBytes,
      imageName: imageName,
      price: price,
      paymentAddress: paymentAddress,
      paymentType: paymentType,
      stars: stars,
    );

    result.fold(
      (error) => emit(PaymentError(message: error)),
      (data) {
        emit(PaymentSuccess(data: data));
        loadMarketData(isRefresh: true);
      },
    );
  }

  Future<void> pinChat({
    required String conversationId,
    required String date,
    required List<String> timeSlots,
  }) async {
    emit(PaymentLoading());
    final result = await marketRepository.pinChat(
      conversationId: conversationId,
      date: date,
      timeSlots: timeSlots,
    );

    result.fold(
      (error) => emit(PaymentError(message: error)),
      (data) {
        emit(PaymentSuccess(data: data));
        loadMarketData(isRefresh: true);
      },
    );
  }
}
