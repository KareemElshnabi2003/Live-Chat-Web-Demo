import 'package:dartz/dartz.dart';
import 'package:live_chat/core/errors/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, Map<String, dynamic>>> login({required String email});
  Future<Either<Failure, Map<String, dynamic>>> register({
    required String name,
    required String userName,
    required String email,
  });
  Future<Either<Failure, Map<String, dynamic>>> checkOTP({
    required String otp,
    required String email,
    String? fcmToken,
  });
  Future<Either<Failure, Map<String, dynamic>>> sendOTP({required String email});
  Future<Either<Failure, Map<String, dynamic>>> resendOTP({required String email});
  Future<Either<Failure, Map<String, dynamic>>> verifyGuest();
  Future<Either<Failure, Unit>> logOut();
}
