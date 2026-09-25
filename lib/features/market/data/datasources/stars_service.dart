import 'package:dio/dio.dart';
import 'package:live_chat/core/api/api_consumer.dart';
import 'package:live_chat/core/api/end_points.dart';
import 'package:live_chat/core/constant/app_constant.dart';
import 'package:live_chat/core/di/service_locator.dart';
import 'package:live_chat/core/helper/cache_helper.dart';

class StarsPurchaseService {
  final ApiConsumer api = sl<ApiConsumer>();

  String get deviceId =>
      CacheHelper.getString(key: AppConstants.deviceIdKey) ?? "";

  Future<dynamic> getPaymentOptions() async {
    try {
      final response = await api.get(
        '${EndPoints.manualPaymentOptions}?device_id=$deviceId',
      );
      if (response != null && response is Map && response['data'] != null) {
        return response['data'];
      }
      return response;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<dynamic> getPaymentMethods() async {
    try {
      final response = await api.get(
        '${EndPoints.manualPaymentData}?device_id=$deviceId',
      );
      if (response != null && response is Map && response['data'] != null) {
        return response['data'];
      }
      return response;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<dynamic> submitManualPayment({
    dynamic image, // can be XFile, Uint8List, or String
    required int price,
    required String paymentAddress,
    required String paymentType,
    required int stars,
  }) async {
    try {
      dynamic fileField;
      if (image != null) {
        if (image is List<int>) {
          fileField = MultipartFile.fromBytes(image, filename: 'receipt.jpg');
        } else if (image is String) {
          fileField = await MultipartFile.fromFile(image);
        }
      }

      final Map<String, dynamic> data = {
        'price': price,
        'paymentAddress': paymentAddress,
        'paymentType': paymentType,
        'stars': stars,
      };
      if (fileField != null) {
        data['image'] = fileField;
      }

      final response = await api.post(
        '${EndPoints.manualPaymentOrders}?device_id=$deviceId',
        data: data,
        isFormData: true,
      );
      return response;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> createPaymentUrl({
    required String numberOfStars,
  }) async {
    try {
      final response = await api.post(
        '${EndPoints.baseUrl}/your_payment_endpoint?device_id=$deviceId',
        data: {'stars': numberOfStars},
      );
      if (response is Map<String, dynamic>) {
        return response;
      }
      return {'status': 'error', 'message': 'Failed to create payment URL'};
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }
}

class StarsService {
  final ApiConsumer api = sl<ApiConsumer>();

  String get deviceId =>
      CacheHelper.getString(key: AppConstants.deviceIdKey) ?? "";

  Future<Map<String, dynamic>> sendStars(
      String email, String numberOfStars) async {
    try {
      final response = await api.post(
        "${EndPoints.sendStars}?device_id=$deviceId",
        data: {
          'email': email,
          'number_of_stars': numberOfStars,
        },
      );
      if (response is Map<String, dynamic>) {
        return response;
      }
      return {'status': 'success', 'data': response};
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }
}
