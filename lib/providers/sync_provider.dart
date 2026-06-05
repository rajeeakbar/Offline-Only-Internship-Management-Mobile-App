import 'package:flutter/material.dart';

class SyncProvider with ChangeNotifier {
  bool _isSyncing = false;
  DateTime? _lastSync;
  bool _isOnline = true;

  bool get isSyncing => _isSyncing;
  DateTime? get lastSync => _lastSync;
  bool get isOnline => _isOnline;

  Future<void> syncData() async {
    if (_isSyncing) return;

    _isSyncing = true;
    notifyListeners();

    // Simulate network latency
    await Future.delayed(const Duration(seconds: 2));

    _isSyncing = false;
    _lastSync = DateTime.now();
    notifyListeners();
  }

  void toggleOnlineStatus(bool status) {
    _isOnline = status;
    notifyListeners();
  }
}
