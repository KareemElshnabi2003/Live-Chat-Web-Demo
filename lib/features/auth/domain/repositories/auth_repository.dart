import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  Future<Either<String, dynamic>> login({required String email});
  Future<Either<String, dynamic>> register({
    required String name,
    required String userName,
    required String email,
  });
  Future<Either<String, dynamic>> checkOTP({
    required String otp,
    required String email,
    String? fcmToken,
  });
  Future<Either<String, dynamic>> sendOTP({required String email});
  Future<Either<String, dynamic>> resendOTP({required String email});
  Future<Either<String, dynamic>> verifyGuest();
  Future<Either<String, dynamic>> logOut();
}
