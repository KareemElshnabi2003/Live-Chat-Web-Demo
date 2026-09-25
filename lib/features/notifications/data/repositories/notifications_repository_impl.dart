import 'package:dartz/dartz.dart';
import 'package:live_chat/core/errors/server_exceptions.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_remote_data_source.dart';
import '../models/notify_model.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource remoteDataSource;

  NotificationsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, List<NotifyModel>>> getNotifications() async {
    try {
      final response = await remoteDataSource.getNotifications();
      if (response != null && response is Map && response['data'] is List) {
        final list = (response['data'] as List)
            .map((e) => NotifyModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        return Right(list);
      }
      return const Right([]);
    } on ServerException catch (e) {
      return Left(e.errorModel.errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
