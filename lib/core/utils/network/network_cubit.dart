import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum NetworkStatus { connected, disconnected }

class NetworkCubit extends Cubit<NetworkStatus> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _subscription;

  NetworkCubit() : super(NetworkStatus.connected) {
    _init();
  }

  void _init() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateStatus(result);

      _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
    } catch (e) {
      // Ignore if platform not supported or error occurs
    }
  }

  void _updateStatus(dynamic result) {
    bool isOffline = false;

    // Handle both new connectivity_plus version (List) and old version (single item)
    if (result is List<ConnectivityResult>) {
      isOffline = result.contains(ConnectivityResult.none) && result.length == 1;
    } else if (result is ConnectivityResult) {
      isOffline = result == ConnectivityResult.none;
    }

    if (isOffline) {
      emit(NetworkStatus.disconnected);
    } else {
      emit(NetworkStatus.connected);
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
