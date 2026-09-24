import 'package:dio/dio.dart';
import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/end_points.dart';
import '../../../../core/constant/app_constant.dart';
import '../../../../core/helper/cache_helper.dart';

abstract class MarketRemoteDataSource {
  Future<dynamic> getProfile();
  Future<dynamic> getStorePowers({int page = 1, int perPage = 20});
  Future<dynamic> closePower({required String powerId, required String status});
  Future<dynamic> getPaymentOptions();
  Future<dynamic> getPaymentMethods();
  Future<dynamic> submitManualPayment({
    required List<int> imageBytes,
    required String imageName,
    required int price,
    required String paymentAddress,
    required String paymentType,
    required int stars,
  });
  Future<dynamic> getAvailableTimeSlots({required String date});
  Future<dynamic> pinChat({
    required String conversationId,
    required String date,
    required List<String> timeSlots,
  });
}

class MarketRemoteDataSourceImpl implements MarketRemoteDataSource {
  final ApiConsumer api;

  MarketRemoteDataSourceImpl({required this.api});

  String get _deviceId =>
      CacheHelper.getString(key: AppConstants.deviceIdKey) ?? "";

  @override
  Future<dynamic> getProfile() async {
    return await api.get(EndPoints.getProfileUrl);
  }

  @override
  Future<dynamic> getStorePowers({int page = 1, int perPage = 20}) async {
    return await api.get(
      "${EndPoints.storePower}?per_page=$perPage&page=$page",
    );
  }

  @override
  Future<dynamic> closePower({
    required String powerId,
    required String status,
  }) async {
    return await api.patch(
      "${EndPoints.getUserPower}/$powerId?device_id=$_deviceId",
      data: {"status": status},
    );
  }

  @override
  Future<dynamic> getPaymentOptions() async {
    return await api.get(
      "${EndPoints.manualPaymentOptions}?device_id=$_deviceId",
    );
  }

  @override
  Future<dynamic> getPaymentMethods() async {
    return await api.get(
      "${EndPoints.manualPaymentData}?device_id=$_deviceId",
    );
  }

  @override
  Future<dynamic> submitManualPayment({
    required List<int> imageBytes,
    required String imageName,
    required int price,
    required String paymentAddress,
    required String paymentType,
    required int stars,
  }) async {
    final formData = FormData.fromMap({
      'price': price,
      'paymentAddress': paymentAddress,
      'paymentType': paymentType,
      'stars': stars,
      'image': MultipartFile.fromBytes(
        imageBytes,
        filename: imageName,
      ),
    });

    return await api.post(
      "${EndPoints.manualPaymentOrders}?device_id=$_deviceId",
      data: formData,
    );
  }

  @override
  Future<dynamic> getAvailableTimeSlots({required String date}) async {
    return await api.get(
      "${EndPoints.getAvailableTime}?date=$date&device_id=$_deviceId",
    );
  }

  @override
  Future<dynamic> pinChat({
    required String conversationId,
    required String date,
    required List<String> timeSlots,
  }) async {
    return await api.post(
      EndPoints.pinChat,
      data: {
        "conversation_id": conversationId,
        "date": date,
        "time_slots": timeSlots,
        "device_id": _deviceId,
      },
    );
  }
}
