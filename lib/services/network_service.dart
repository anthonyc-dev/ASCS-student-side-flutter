import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  final Connectivity _connectivity = Connectivity();
  final _connectionController = StreamController<bool>.broadcast();

  Stream<bool> get connectionStream => _connectionController.stream;
  bool _isOnline = true;

  NetworkService() {
    _init();
  }

  Future<void> _init() async {
    // Check initial connectivity
    _isOnline = await checkConnectivity();
    _connectionController.add(_isOnline);

    // Listen to connectivity changes
    _connectivity.onConnectivityChanged.listen((result) async {
      final isOnline = await _checkInternetConnection();
      if (_isOnline != isOnline) {
        _isOnline = isOnline;
        _connectionController.add(_isOnline);
      }
    });
  }

  Future<bool> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      if (result.contains(ConnectivityResult.none)) {
        _isOnline = false;
        return false;
      }
      // Check actual internet connection
      return await _checkInternetConnection();
    } catch (e) {
      return false;
    }
  }

  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _isOnline = true;
        return true;
      }
    } catch (_) {
      _isOnline = false;
      return false;
    }
    _isOnline = false;
    return false;
  }

  bool get isOnline => _isOnline;

  void dispose() {
    _connectionController.close();
  }
}
