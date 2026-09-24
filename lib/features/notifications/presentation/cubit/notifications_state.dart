abstract class NotificationsState {}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsLoaded extends NotificationsState {
  final List<dynamic> notifications;
  NotificationsLoaded({this.notifications = const []});
}

class NotificationsError extends NotificationsState {
  final String message;
  NotificationsError({required this.message});
}
