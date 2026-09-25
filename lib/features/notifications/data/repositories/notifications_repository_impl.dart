import 'package:dartz/dartz.dart';
import 'package:live_chat/core/errors/server_exceptions.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_remote_data_source.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource remoteDataSource;

  NotificationsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, List<dynamic>>> getNotifications() async {
    try {
      final response = await remoteDataSource.getNotifications();
      if (response != null && response is Map && response['data'] is List) {
        return Right(response['data'] as List<dynamic>);
      }
      return const Right([]);
    } on ServerException catch (e) {
      return Left(e.errorModel.errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
