import 'package:dartz/dartz.dart';

abstract class NotificationsRepository {
  Future<Either<String, List<dynamic>>> getNotifications();
}
