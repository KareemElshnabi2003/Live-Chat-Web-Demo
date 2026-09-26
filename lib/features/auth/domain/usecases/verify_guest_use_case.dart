import 'package:dartz/dartz.dart';
import 'package:live_chat/core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class VerifyGuestUseCase {
  final AuthRepository repository;
  VerifyGuestUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call() {
    return repository.verifyGuest();
  }
}
