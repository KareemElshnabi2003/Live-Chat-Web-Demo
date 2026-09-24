import 'package:dio/dio.dart';
import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/end_points.dart';
import '../../../../core/constant/app_constant.dart';
import '../../../../core/helper/cache_helper.dart';

abstract class ChatRemoteDataSource {
  Future<dynamic> getMessages({required String chatId, int page = 1});
  Future<dynamic> sendMessage({
    required String chatId,
    required String message,
  });
  Future<dynamic> sendMessageWithFile({
    required String chatId,
    required String messageType,
    MultipartFile? file,
  });
  Future<dynamic> sendReaction({
    required String messageId,
    required String react,
  });
  Future<dynamic> getMembers({required String chatId, int page = 1});
  Future<dynamic> getRadios();
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final ApiConsumer api;

  ChatRemoteDataSourceImpl({required this.api});

  String get _deviceId =>
      CacheHelper.getString(key: AppConstants.deviceIdKey) ?? "";

  @override
  Future<dynamic> getMessages({required String chatId, int page = 1}) async {
    return await api.get(
      "${EndPoints.getMessagesChatUrl}?conversation_id=$chatId&page=$page&per_page=20&device_id=$_deviceId",
    );
  }

  @override
  Future<dynamic> sendMessage({
    required String chatId,
    required String message,
  }) async {
    return await api.post(
      EndPoints.sendMessagesUrl,
      data: {
        "conversation_id": chatId,
        "message": message,
        "message_type": "text",
        "device_id": _deviceId,
      },
    );
  }

  @override
  Future<dynamic> sendMessageWithFile({
    required String chatId,
    required String messageType,
    MultipartFile? file,
  }) async {
    final Map<String, dynamic> data = {
      "conversation_id": chatId,
      "message_type": messageType,
      "device_id": _deviceId,
    };
    if (file != null) {
      data["message"] = file;
    }
    return await api.post(
      EndPoints.sendMessagesUrl,
      data: data,
      isFormData: true,
    );
  }

  @override
  Future<dynamic> sendReaction({
    required String messageId,
    required String react,
  }) async {
    return await api.post(
      EndPoints.reactToMessageUrl,
      data: {
        "message_id": messageId,
        "react": react,
        "device_id": _deviceId,
      },
    );
  }

  @override
  Future<dynamic> getMembers({required String chatId, int page = 1}) async {
    return await api.get(
      "${EndPoints.getMemberChatUrl}/$chatId?per_page=20&page=$page",
    );
  }

  @override
  Future<dynamic> getRadios() async {
    return await api.get(EndPoints.getRadiosUrl);
  }
}
