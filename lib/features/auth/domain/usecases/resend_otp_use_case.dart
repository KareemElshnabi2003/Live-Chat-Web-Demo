import 'package:dartz/dartz.dart';
import '../repositories/auth_repository.dart';

class ResendOtpUseCase {
  final AuthRepository repository;
  ResendOtpUseCase(this.repository);

  Future<Either<String, dynamic>> call({required String email}) {
    return repository.resendOTP(email: email);
  }
}
