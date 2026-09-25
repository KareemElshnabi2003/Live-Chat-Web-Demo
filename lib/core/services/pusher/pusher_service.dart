import 'dart:async';
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
  Future<void>? _initFuture;
  StreamSubscription<PusherEvent>? _initSubscription;
  final Set<String> _subscribedChannels = {};
  final StreamController<PusherEvent> _eventController = StreamController<PusherEvent>.broadcast();

  bool get isInitialized => _isInitialized;

  Stream<PusherEvent> get eventStream => _eventController.stream;

  Stream<PusherEvent> eventStreamForChannel(String channelName) =>
      _eventController.stream.where((event) => event.channelName == channelName);

  StreamSubscription<PusherEvent> listenToChannel({
    required String channelName,
    required void Function(PusherEvent event) onEvent,
  }) {
    return eventStreamForChannel(channelName).listen(onEvent);
  }

  Future<void> init({void Function(PusherEvent)? onEvent}) async {
    if (onEvent != null) {
      await _initSubscription?.cancel();
      _initSubscription = _eventController.stream.listen(onEvent);
    }
    if (_isInitialized) return;
    if (_initFuture != null) return _initFuture;

    _initFuture = _doInit();
    try {
      await _initFuture;
    } finally {
      _initFuture = null;
    }
  }

  Future<void> _doInit() async {
    try {
      _pusher = PusherChannelsFlutter.getInstance();
      await _pusher!.init(
        apiKey: apiKey,
        cluster: cluster,
        onEvent: (event) {
          log("Pusher event: ${event.eventName} on channel: ${event.channelName}");
          if (!_eventController.isClosed) {
            _eventController.add(event);
          }
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

  Future<void> reconnect() async {
    if (_pusher != null) {
      try {
        await _pusher!.connect();
      } catch (e) {
        debugPrint("Pusher reconnect error: $e");
      }
    } else {
      await init();
    }
  }

  Future<void> disconnect() async {
    await _initSubscription?.cancel();
    _initSubscription = null;
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

  void dispose() {
    disconnect();
    _eventController.close();
  }
}
