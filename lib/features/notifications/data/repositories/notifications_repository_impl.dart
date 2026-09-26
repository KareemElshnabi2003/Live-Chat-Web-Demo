import 'package:dartz/dartz.dart';
import 'package:live_chat/core/errors/failures.dart';
import 'package:live_chat/core/errors/server_exceptions.dart';
import '../../domain/entities/notify_entity.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_remote_data_source.dart';
import '../models/notify_model.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource remoteDataSource;

  NotificationsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<NotifyEntity>>> getNotifications() async {
    try {
      final response = await remoteDataSource.getNotifications();
      if (response['data'] is List) {
        final list = (response['data'] as List)
            .map((e) => NotifyModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        return Right(list);
      }
      return const Right([]);
    } on ServerException catch (e) {
      return Left(ServerFailure.fromServerException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
