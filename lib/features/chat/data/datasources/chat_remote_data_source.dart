import 'package:dio/dio.dart';
import 'package:live_chat/core/api/api_consumer.dart';
import 'package:live_chat/core/api/end_points.dart';
import 'package:live_chat/core/constant/app_constant.dart';
import 'package:live_chat/core/helper/cache_helper.dart';
import '../../domain/entities/chat_attachment.dart';

abstract class ChatRemoteDataSource {
  Future<Map<String, dynamic>> getMessages({required String chatId, int page = 1});
  Future<Map<String, dynamic>> sendMessage({
    required String chatId,
    required String message,
  });
  Future<Map<String, dynamic>> sendMessageWithFile({
    required String chatId,
    required String messageType,
    ChatAttachment? file,
  });
  Future<Map<String, dynamic>> sendReaction({
    required String messageId,
    required String react,
  });
  Future<Map<String, dynamic>> getMembers({required String chatId, int page = 1});
  Future<Map<String, dynamic>> getRadios();
  Future<Map<String, dynamic>> getThemes();
  Future<Map<String, dynamic>> createGeneralChat({
    required Map<String, dynamic> data,
    ChatAttachment? imgChat,
    ChatAttachment? bgChat,
  });
  Future<Map<String, dynamic>> updateGeneralChat({
    required String chatId,
    required Map<String, dynamic> data,
    ChatAttachment? imgChat,
    ChatAttachment? bgChat,
  });
  Future<Map<String, dynamic>> deleteChat({required String chatId});
  Future<Map<String, dynamic>> acceptMemberToChat({
    required String chatId,
    required String userId,
  });
  Future<Map<String, dynamic>> blockOrUnBlock({
    required int status,
    required String userId,
  });
  Future<Map<String, dynamic>> createChatFriend({required int friendId});
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final ApiConsumer api;

  ChatRemoteDataSourceImpl({required this.api});

  String get _deviceId =>
      CacheHelper.getString(key: AppConstants.deviceIdKey) ?? "";

  MultipartFile? _toMultipart(ChatAttachment? attachment) {
    if (attachment == null) return null;
    return MultipartFile.fromBytes(attachment.bytes, filename: attachment.filename);
  }

  Map<String, dynamic> _toMap(dynamic response) {
    if (response is Map<String, dynamic>) return response;
    if (response is Map) return Map<String, dynamic>.from(response);
    return <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> getMessages({required String chatId, int page = 1}) async {
    final response = await api.get(
      "${EndPoints.getMessagesChatUrl}?conversation_id=$chatId&page=$page&per_page=20&device_id=$_deviceId",
    );
    return _toMap(response);
  }

  @override
  Future<Map<String, dynamic>> sendMessage({
    required String chatId,
    required String message,
  }) async {
    final response = await api.post(
      EndPoints.sendMessagesUrl,
      data: {
        "conversation_id": chatId,
        "message": message,
        "message_type": "text",
        "device_id": _deviceId,
      },
    );
    return _toMap(response);
  }

  @override
  Future<Map<String, dynamic>> sendMessageWithFile({
    required String chatId,
    required String messageType,
    ChatAttachment? file,
  }) async {
    final Map<String, dynamic> data = {
      "conversation_id": chatId,
      "message_type": messageType,
      "device_id": _deviceId,
    };
    final multipart = _toMultipart(file);
    if (multipart != null) {
      data["message"] = multipart;
    }
    final response = await api.post(
      EndPoints.sendMessagesUrl,
      data: data,
      isFormData: true,
    );
    return _toMap(response);
  }

  @override
  Future<Map<String, dynamic>> sendReaction({
    required String messageId,
    required String react,
  }) async {
    final response = await api.post(
      EndPoints.reactToMessageUrl,
      data: {
        "message_id": messageId,
        "react": react,
        "device_id": _deviceId,
      },
    );
    return _toMap(response);
  }

  @override
  Future<Map<String, dynamic>> getMembers({required String chatId, int page = 1}) async {
    final response = await api.get(
      "${EndPoints.getMemberChatUrl}/$chatId?per_page=20&page=$page&device_id=$_deviceId",
    );
    return _toMap(response);
  }

  @override
  Future<Map<String, dynamic>> getRadios() async {
    final response = await api.get(
      "${EndPoints.getRadiosUrl}?device_id=$_deviceId",
    );
    return _toMap(response);
  }

  @override
  Future<Map<String, dynamic>> getThemes() async {
    final response = await api.get(
      "${EndPoints.getThemesUrl}?device_id=$_deviceId",
    );
    return _toMap(response);
  }

  @override
  Future<Map<String, dynamic>> createGeneralChat({
    required Map<String, dynamic> data,
    ChatAttachment? imgChat,
    ChatAttachment? bgChat,
  }) async {
    final map = Map<String, dynamic>.from(data);
    map['device_id'] = _deviceId;
    final imgPart = _toMultipart(imgChat);
    final bgPart = _toMultipart(bgChat);
    if (imgPart != null) map['image'] = imgPart;
    if (bgPart != null) map['bg_image'] = bgPart;
    final response = await api.post(
      "${EndPoints.conversations}?device_id=$_deviceId",
      data: map,
      isFormData: true,
    );
    return _toMap(response);
  }

  @override
  Future<Map<String, dynamic>> updateGeneralChat({
    required String chatId,
    required Map<String, dynamic> data,
    ChatAttachment? imgChat,
    ChatAttachment? bgChat,
  }) async {
    final map = Map<String, dynamic>.from(data);
    map['device_id'] = _deviceId;
    map['_method'] = 'PATCH';
    final imgPart = _toMultipart(imgChat);
    final bgPart = _toMultipart(bgChat);
    if (imgPart != null) map['image'] = imgPart;
    if (bgPart != null) map['bg_image'] = bgPart;
    final response = await api.post(
      "${EndPoints.conversations}/$chatId?device_id=$_deviceId",
      data: map,
      isFormData: true,
    );
    return _toMap(response);
  }

  @override
  Future<Map<String, dynamic>> deleteChat({required String chatId}) async {
    final response = await api.delete(
      "${EndPoints.conversations}/$chatId?device_id=$_deviceId",
    );
    return _toMap(response);
  }

  @override
  Future<Map<String, dynamic>> acceptMemberToChat({
    required String chatId,
    required String userId,
  }) async {
    final response = await api.post(
      "${EndPoints.acceptMemberToChat}?device_id=$_deviceId",
      data: {
        "conversation_id": chatId,
        "user_id": userId,
      },
    );
    return _toMap(response);
  }

  @override
  Future<Map<String, dynamic>> blockOrUnBlock({
    required int status,
    required String userId,
  }) async {
    final response = await api.post(
      "${EndPoints.blockUrl}/$userId/block?device_id=$_deviceId",
      data: {
        "block": status,
      },
    );
    return _toMap(response);
  }

  @override
  Future<Map<String, dynamic>> createChatFriend({required int friendId}) async {
    final response = await api.post(
      "${EndPoints.createChatFriendUrl}?device_id=$_deviceId",
      data: {
        "member": friendId,
      },
    );
    return _toMap(response);
  }
}
