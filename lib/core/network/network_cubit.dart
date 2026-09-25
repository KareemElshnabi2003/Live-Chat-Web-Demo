import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'network_info.dart';
import 'network_state.dart';

class NetworkCubit extends Cubit<NetworkStatus> {
  final NetworkInfo networkInfo;
  StreamSubscription<List<ConnectivityResult>>? _connectionSubscription;

  NetworkCubit(this.networkInfo) : super(NetworkStatus.initial) {
    checkConnection();
    startListening();
  }

  Future<void> checkConnection() async {
    final isConnected = await networkInfo.isConnected;
    emit(isConnected ? NetworkStatus.connected : NetworkStatus.disconnected);
  }

  void startListening() {
    _connectionSubscription?.cancel();
    _connectionSubscription = networkInfo.onStatusChange.listen((results) {
      if (results.contains(ConnectivityResult.none)) {
        emit(NetworkStatus.disconnected);
      } else {
        emit(NetworkStatus.connected);
      }
    });
  }

  @override
  Future<void> close() {
    _connectionSubscription?.cancel();
    return super.close();
  }
}