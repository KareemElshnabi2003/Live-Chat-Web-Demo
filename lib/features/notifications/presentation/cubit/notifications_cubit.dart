import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/notifications_repository.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationsRepository notificationsRepository;

  NotificationsCubit({required this.notificationsRepository})
      : super(NotificationsInitial());

  Future<void> getNotifications() async {
    emit(NotificationsLoading());
    final result = await notificationsRepository.getNotifications();
    result.fold(
      (error) => emit(NotificationsError(message: error)),
      (notifications) => emit(NotificationsLoaded(notifications: notifications)),
    );
  }
}
