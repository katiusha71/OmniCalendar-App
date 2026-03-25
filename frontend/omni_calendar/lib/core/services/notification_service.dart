import 'package:flutter/foundation.dart';

class NotificationService {
  NotificationService();

  Future<void> initialize() async {
    // Push notifications disabled - Firebase not configured
    debugPrint('NotificationService: Push notifications are disabled');
  }
}
