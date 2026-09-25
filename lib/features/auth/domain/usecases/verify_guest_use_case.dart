import 'package:dartz/dartz.dart';
import '../repositories/auth_repository.dart';

class VerifyGuestUseCase {
  final AuthRepository repository;
  VerifyGuestUseCase(this.repository);

  Future<Either<String, dynamic>> call() {
    return repository.verifyGuest();
  }
}
