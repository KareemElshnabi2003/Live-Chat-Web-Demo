import 'package:dartz/dartz.dart';
import '../repositories/notifications_repository.dart';

class GetNotificationsUseCase {
  final NotificationsRepository repository;
  GetNotificationsUseCase(this.repository);

  Future<Either<String, List<dynamic>>> call() {
    return repository.getNotifications();
  }
}
