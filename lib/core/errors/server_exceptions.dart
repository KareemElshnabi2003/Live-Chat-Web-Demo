import 'package:dio/dio.dart';
import 'error_model.dart';

class ServerException implements Exception {
  final ErrorModel errorModel;
  ServerException({required this.errorModel});
}

void handleDioException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
      throw ServerException(
        errorModel: ErrorModel(
          status: 408,
          errorMessage: 'انتهى وقت الاتصال بالسيرفر',
        ),
      );
    case DioExceptionType.sendTimeout:
      throw ServerException(
        errorModel: ErrorModel(
          status: 408,
          errorMessage: 'انتهى وقت إرسال البيانات',
        ),
      );
    case DioExceptionType.receiveTimeout:
      throw ServerException(
        errorModel: ErrorModel(
          status: 408,
          errorMessage: 'انتهى وقت استقبال البيانات',
        ),
      );
    case DioExceptionType.connectionError:
      throw ServerException(
        errorModel: ErrorModel(
          status: 503,
          errorMessage: 'لا يوجد اتصال بالإنترنت',
        ),
      );
    case DioExceptionType.cancel:
      throw ServerException(
        errorModel: ErrorModel(status: 499, errorMessage: 'تم إلغاء الطلب'),
      );

    case DioExceptionType.badResponse:
      if (e.response != null && e.response?.data != null) {
        throw ServerException(
          errorModel: ErrorModel.fromJson(e.response?.data),
        );
      } else {
        throw ServerException(
          errorModel: ErrorModel(
            status: e.response?.statusCode ?? 500,
            errorMessage: 'حدث خطأ في السيرفر',
          ),
        );
      }

    case DioExceptionType.badCertificate:
      throw ServerException(
        errorModel: ErrorModel(
          status: 500,
          errorMessage: 'مشكلة في شهادة الحماية (Certificate)',
        ),
      );
    case DioExceptionType.unknown:
    default:
      throw ServerException(
        errorModel: ErrorModel(status: 500, errorMessage: 'حدث خطأ غير متوقع'),
      );
  }
}
