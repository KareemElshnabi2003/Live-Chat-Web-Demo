import 'package:dartz/dartz.dart';

abstract class MarketRepository {
  Future<Either<String, Map<String, dynamic>>> getProfile();
  Future<Either<String, List<dynamic>>> getStorePowers({int page = 1, int perPage = 20});
  Future<Either<String, dynamic>> closePower({required String powerId, required String status});
  Future<Either<String, dynamic>> getPaymentOptions();
  Future<Either<String, dynamic>> getPaymentMethods();
  Future<Either<String, dynamic>> submitManualPayment({
    required List<int> imageBytes,
    required String imageName,
    required int price,
    required String paymentAddress,
    required String paymentType,
    required int stars,
  });
  Future<Either<String, List<dynamic>>> getAvailableTimeSlots({required String date});
  Future<Either<String, dynamic>> pinChat({
    required String conversationId,
    required String date,
    required List<String> timeSlots,
  });
}
