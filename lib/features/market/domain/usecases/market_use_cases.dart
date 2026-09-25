import 'package:dartz/dartz.dart';
import '../repositories/market_repository.dart';

class GetMarketProfileUseCase {
  final MarketRepository repository;
  GetMarketProfileUseCase(this.repository);

  Future<Either<String, Map<String, dynamic>>> call() {
    return repository.getProfile();
  }
}

class GetStorePowersUseCase {
  final MarketRepository repository;
  GetStorePowersUseCase(this.repository);

  Future<Either<String, List<dynamic>>> call({int page = 1, int perPage = 20}) {
    return repository.getStorePowers(page: page, perPage: perPage);
  }
}

class ClosePowerUseCase {
  final MarketRepository repository;
  ClosePowerUseCase(this.repository);

  Future<Either<String, dynamic>> call({required String powerId, required String status}) {
    return repository.closePower(powerId: powerId, status: status);
  }
}

class GetPaymentOptionsUseCase {
  final MarketRepository repository;
  GetPaymentOptionsUseCase(this.repository);

  Future<Either<String, dynamic>> call() {
    return repository.getPaymentOptions();
  }
}

class SubmitManualPaymentUseCase {
  final MarketRepository repository;
  SubmitManualPaymentUseCase(this.repository);

  Future<Either<String, dynamic>> call({
    required List<int> imageBytes,
    required String imageName,
    required int price,
    required String paymentAddress,
    required String paymentType,
    required int stars,
  }) {
    return repository.submitManualPayment(
      imageBytes: imageBytes,
      imageName: imageName,
      price: price,
      paymentAddress: paymentAddress,
      paymentType: paymentType,
      stars: stars,
    );
  }
}

class GetAvailableTimeSlotsUseCase {
  final MarketRepository repository;
  GetAvailableTimeSlotsUseCase(this.repository);

  Future<Either<String, List<dynamic>>> call({required String date}) {
    return repository.getAvailableTimeSlots(date: date);
  }
}

class PinChatUseCase {
  final MarketRepository repository;
  PinChatUseCase(this.repository);

  Future<Either<String, dynamic>> call({
    required String conversationId,
    required String date,
    required List<String> timeSlots,
  }) {
    return repository.pinChat(
      conversationId: conversationId,
      date: date,
      timeSlots: timeSlots,
    );
  }
}
