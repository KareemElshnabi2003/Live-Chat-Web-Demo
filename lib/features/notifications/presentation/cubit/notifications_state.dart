import '../../domain/entities/notify_entity.dart';

abstract class NotificationsState {}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsLoaded extends NotificationsState {
  final List<NotifyEntity> notifications;

  NotificationsLoaded({required this.notifications});
}

class NotificationsError extends NotificationsState {
  final String message;

  NotificationsError({required this.message});
}
