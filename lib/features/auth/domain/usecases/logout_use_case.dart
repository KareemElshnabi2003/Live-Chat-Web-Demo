import 'package:dartz/dartz.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository repository;
  LogoutUseCase(this.repository);

  Future<Either<String, dynamic>> call() {
    return repository.logOut();
  }
}
