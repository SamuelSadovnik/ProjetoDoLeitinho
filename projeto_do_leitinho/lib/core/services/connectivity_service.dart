import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final _controller = StreamController<bool>.broadcast();

  Stream<bool> get connectionStream => _controller.stream;
  bool _isConnected = true;

  ConnectivityService() {
    _initConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      print('Connectivity check error: $e');
      _isConnected = false;
      _controller.add(false);
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final wasConnected = _isConnected;
    _isConnected = !results.contains(ConnectivityResult.none);

    if (wasConnected != _isConnected) {
      _controller.add(_isConnected);
      print(
        'Connection status changed: ${_isConnected ? "Online" : "Offline"}',
      );
    }
  }

  bool get isConnected => _isConnected;

  Future<bool> checkConnection() async {
    final results = await _connectivity.checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }

  void dispose() {
    _controller.close();
  }
}
