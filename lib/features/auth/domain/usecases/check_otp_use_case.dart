import 'package:dartz/dartz.dart';
import '../repositories/auth_repository.dart';

class CheckOtpUseCase {
  final AuthRepository repository;
  CheckOtpUseCase(this.repository);

  Future<Either<String, dynamic>> call({
    required String email,
    required String otp,
    String? fcmToken,
  }) {
    return repository.checkOTP(email: email, otp: otp, fcmToken: fcmToken);
  }
}
