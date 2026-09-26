import 'package:dartz/dartz.dart';
import 'package:live_chat/core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({required String email}) {
    return repository.login(email: email);
  }
}
