import 'package:dartz/dartz.dart';
import '../../data/models/notify_model.dart';

abstract class NotificationsRepository {
  Future<Either<String, List<NotifyModel>>> getNotifications();
}
