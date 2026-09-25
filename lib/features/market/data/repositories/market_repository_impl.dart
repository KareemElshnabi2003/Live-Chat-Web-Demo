import 'package:dartz/dartz.dart';
import 'package:live_chat/core/errors/server_exceptions.dart';
import '../../domain/repositories/market_repository.dart';
import '../datasources/market_remote_data_source.dart';

class MarketRepositoryImpl implements MarketRepository {
  final MarketRemoteDataSource remoteDataSource;

  MarketRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, Map<String, dynamic>>> getProfile() async {
    try {
      final response = await remoteDataSource.getProfile();
      if (response != null && response is Map && response['data'] is Map) {
        return Right(Map<String, dynamic>.from(response['data']));
      }
      return const Right({});
    } on ServerException catch (e) {
      return Left(e.errorModel.errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<dynamic>>> getStorePowers({int page = 1, int perPage = 20}) async {
    try {
      final response = await remoteDataSource.getStorePowers(page: page, perPage: perPage);
      if (response != null && response is Map && response['data'] is List) {
        return Right(response['data'] as List<dynamic>);
      }
      return const Right([]);
    } on ServerException catch (e) {
      return Left(e.errorModel.errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, dynamic>> closePower({required String powerId, required String status}) async {
    try {
      final response = await remoteDataSource.closePower(powerId: powerId, status: status);
      return Right(response);
    } on ServerException catch (e) {
      return Left(e.errorModel.errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, dynamic>> getPaymentOptions() async {
    try {
      final response = await remoteDataSource.getPaymentOptions();
      return Right(response);
    } on ServerException catch (e) {
      return Left(e.errorModel.errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, dynamic>> getPaymentMethods() async {
    try {
      final response = await remoteDataSource.getPaymentMethods();
      return Right(response);
    } on ServerException catch (e) {
      return Left(e.errorModel.errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, dynamic>> submitManualPayment({
    required List<int> imageBytes,
    required String imageName,
    required int price,
    required String paymentAddress,
    required String paymentType,
    required int stars,
  }) async {
    try {
      final response = await remoteDataSource.submitManualPayment(
        imageBytes: imageBytes,
        imageName: imageName,
        price: price,
        paymentAddress: paymentAddress,
        paymentType: paymentType,
        stars: stars,
      );
      return Right(response);
    } on ServerException catch (e) {
      return Left(e.errorModel.errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<dynamic>>> getAvailableTimeSlots({required String date}) async {
    try {
      final response = await remoteDataSource.getAvailableTimeSlots(date: date);
      if (response != null && response is Map && response['data'] is List) {
        return Right(response['data'] as List<dynamic>);
      }
      return const Right([]);
    } on ServerException catch (e) {
      return Left(e.errorModel.errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, dynamic>> pinChat({
    required String conversationId,
    required String date,
    required List<String> timeSlots,
  }) async {
    try {
      final response = await remoteDataSource.pinChat(
        conversationId: conversationId,
        date: date,
        timeSlots: timeSlots,
      );
      return Right(response);
    } on ServerException catch (e) {
      return Left(e.errorModel.errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
