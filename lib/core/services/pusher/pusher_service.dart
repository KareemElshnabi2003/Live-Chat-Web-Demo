import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class PusherService {
  static final PusherService _instance = PusherService._internal();
  factory PusherService() => _instance;
  PusherService._internal();

  static const String apiKey = "f63bff3d533540e54682";
  static const String cluster = "ap2";

  PusherChannelsFlutter? _pusher;
  bool _isInitialized = false;
  final Set<String> _subscribedChannels = {};
  void Function(PusherEvent)? _eventHandler;

  bool get isInitialized => _isInitialized;

  Future<void> init({required void Function(PusherEvent) onEvent}) async {
    _eventHandler = onEvent;
    if (_isInitialized) return;

    try {
      _pusher = PusherChannelsFlutter.getInstance();
      await _pusher!.init(
        apiKey: apiKey,
        cluster: cluster,
        onEvent: (event) {
          log("Pusher event: ${event.eventName} on channel: ${event.channelName}");
          _eventHandler?.call(event);
        },
        onError: (message, code, error) {
          debugPrint("Pusher Error: $message (code: $code)");
        },
        onSubscriptionSucceeded: (channelName, data) {
          log("Subscribed to channel: $channelName");
        },
      );
      await _pusher!.connect();
      _isInitialized = true;
    } catch (e) {
      debugPrint("Pusher init error: $e");
    }
  }

  void setEventHandler(void Function(PusherEvent) onEvent) {
    _eventHandler = onEvent;
  }

  Future<void> subscribe(String channelName) async {
    if (_pusher == null) return;
    if (!_subscribedChannels.contains(channelName)) {
      try {
        await _pusher!.subscribe(channelName: channelName);
        _subscribedChannels.add(channelName);
      } catch (e) {
        debugPrint("Pusher subscribe error: $e");
      }
    }
  }

  Future<void> unsubscribe(String channelName) async {
    if (_pusher == null) return;
    if (_subscribedChannels.contains(channelName)) {
      try {
        await _pusher!.unsubscribe(channelName: channelName);
        _subscribedChannels.remove(channelName);
      } catch (e) {
        debugPrint("Pusher unsubscribe error: $e");
      }
    }
  }

  Future<void> disconnect() async {
    if (_pusher != null) {
      for (final channel in _subscribedChannels.toList()) {
        await unsubscribe(channel);
      }
      try {
        await _pusher!.disconnect();
      } catch (e) {
        debugPrint("Pusher disconnect error: $e");
      }
      _isInitialized = false;
    }
  }
}
