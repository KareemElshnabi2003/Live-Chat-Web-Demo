import 'server_exceptions.dart';

abstract class Failure {
  final String message;
  final int? statusCode;

  const Failure(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.statusCode});

  factory ServerFailure.fromServerException(ServerException exception) {
    return ServerFailure(
      exception.errorModel.errorMessage,
      statusCode: exception.errorModel.status,
    );
  }
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'لا يوجد اتصال بالإنترنت']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'حدث خطأ في الذاكرة المؤقتة']);
}
