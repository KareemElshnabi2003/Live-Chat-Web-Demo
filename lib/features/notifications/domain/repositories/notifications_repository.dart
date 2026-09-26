import 'package:dartz/dartz.dart';
import 'package:live_chat/core/errors/failures.dart';
import '../entities/notify_entity.dart';

abstract class NotificationsRepository {
  Future<Either<Failure, List<NotifyEntity>>> getNotifications();
}
