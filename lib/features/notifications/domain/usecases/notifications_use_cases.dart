import 'package:dartz/dartz.dart';
import 'package:live_chat/core/errors/failures.dart';
import '../entities/notify_entity.dart';
import '../repositories/notifications_repository.dart';

class GetNotificationsUseCase {
  final NotificationsRepository repository;
  GetNotificationsUseCase(this.repository);

  Future<Either<Failure, List<NotifyEntity>>> call() {
    return repository.getNotifications();
  }
}
