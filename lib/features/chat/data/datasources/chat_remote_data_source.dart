import 'package:dio/dio.dart';
import 'package:live_chat/core/api/api_consumer.dart';
import 'package:live_chat/core/api/end_points.dart';
import 'package:live_chat/core/constant/app_constant.dart';
import 'package:live_chat/core/helper/cache_helper.dart';
import '../../domain/entities/chat_attachment.dart';

abstract class ChatRemoteDataSource {
  Future<dynamic> getMessages({required String chatId, int page = 1});
  Future<dynamic> sendMessage({
    required String chatId,
    required String message,
  });
  Future<dynamic> sendMessageWithFile({
    required String chatId,
    required String messageType,
    ChatAttachment? file,
  });
  Future<dynamic> sendReaction({
    required String messageId,
    required String react,
  });
  Future<dynamic> getMembers({required String chatId, int page = 1});
  Future<dynamic> getRadios();
  Future<dynamic> getThemes();
  Future<dynamic> createGeneralChat({
    required Map<String, dynamic> data,
    ChatAttachment? imgChat,
    ChatAttachment? bgChat,
  });
  Future<dynamic> updateGeneralChat({
    required String chatId,
    required Map<String, dynamic> data,
    ChatAttachment? imgChat,
    ChatAttachment? bgChat,
  });
  Future<dynamic> deleteChat({required String chatId});
  Future<dynamic> acceptMemberToChat({
    required String chatId,
    required String userId,
  });
  Future<dynamic> blockOrUnBlock({
    required int status,
    required String userId,
  });
  Future<dynamic> createChatFriend({required int friendId});
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
      "${EndPoints.getMemberChatUrl}/$chatId?per_page=20&page=$page&device_id=$_deviceId",
    );
  }

  @override
  Future<dynamic> getRadios() async {
    return await api.get(
      "${EndPoints.getRadiosUrl}?device_id=$_deviceId",
    );
  }

  @override
  Future<dynamic> getThemes() async {
    return await api.get(
      "${EndPoints.getThemesUrl}?device_id=$_deviceId",
    );
  }

  @override
  Future<dynamic> createGeneralChat({
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
    return await api.post(
      "${EndPoints.conversations}?device_id=$_deviceId",
      data: map,
      isFormData: true,
    );
  }

  @override
  Future<dynamic> updateGeneralChat({
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
    return await api.post(
      "${EndPoints.conversations}/$chatId?device_id=$_deviceId",
      data: map,
      isFormData: true,
    );
  }

  @override
  Future<dynamic> deleteChat({required String chatId}) async {
    return await api.delete(
      "${EndPoints.conversations}/$chatId?device_id=$_deviceId",
    );
  }

  @override
  Future<dynamic> acceptMemberToChat({
    required String chatId,
    required String userId,
  }) async {
    return await api.post(
      "${EndPoints.acceptMemberToChat}?device_id=$_deviceId",
      data: {
        "conversation_id": chatId,
        "user_id": userId,
      },
    );
  }

  @override
  Future<dynamic> blockOrUnBlock({
    required int status,
    required String userId,
  }) async {
    return await api.post(
      "${EndPoints.blockUrl}/$userId/block?device_id=$_deviceId",
      data: {
        "block": status,
      },
    );
  }

  @override
  Future<dynamic> createChatFriend({required int friendId}) async {
    return await api.post(
      "${EndPoints.createChatFriendUrl}?device_id=$_deviceId",
      data: {
        "member": friendId,
      },
    );
  }
}
