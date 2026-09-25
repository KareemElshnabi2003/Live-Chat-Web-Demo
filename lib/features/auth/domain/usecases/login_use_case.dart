import 'package:dartz/dartz.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  Future<Either<String, dynamic>> call({required String email}) {
    return repository.login(email: email);
  }
}
