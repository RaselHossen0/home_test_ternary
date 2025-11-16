import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  ConnectivityService._();
  static final ConnectivityService instance = ConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  Stream<bool> get isOnlineStream => _controller.stream;

  Future<void> init() async {
    final results = await _connectivity.checkConnectivity();
    final initialOnline = results.any(_isOnline);
    _controller.add(initialOnline);
    _connectivity.onConnectivityChanged.listen((results) {
      // If any network available, consider online
      final online = results.any(_isOnline);
      _controller.add(online);
    });
  }

  bool _isOnline(ConnectivityResult result) {
    return switch (result) {
      ConnectivityResult.mobile => true,
      ConnectivityResult.wifi => true,
      ConnectivityResult.ethernet => true,
      ConnectivityResult.vpn => true,
      _ => false,
    };
  }
}
