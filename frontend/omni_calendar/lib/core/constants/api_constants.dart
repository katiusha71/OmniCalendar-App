class ApiConstants {
  static const String baseUrl = 'http://localhost:8080/api';

  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String fcmToken = '/auth/fcm-token';

  // Event endpoints
  static const String events = '/events';
  static const String upcomingEvents = '/events/upcoming';

  // Calendar endpoints
  static const String convert = '/calendar/convert';
  static const String today = '/calendar/today';
}
