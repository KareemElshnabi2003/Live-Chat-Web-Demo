import 'package:dartz/dartz.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;
  RegisterUseCase(this.repository);

  Future<Either<String, dynamic>> call({
    required String name,
    required String userName,
    required String email,
  }) {
    return repository.register(name: name, userName: userName, email: email);
  }
}
