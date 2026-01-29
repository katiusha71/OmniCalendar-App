import '../core/constants/app_constants.dart';

class User {
  final int id;
  final String email;
  final String? fullName;
  final CalendarType preferredCalendar;
  final String timezone;

  User({
    required this.id,
    required this.email,
    this.fullName,
    this.preferredCalendar = CalendarType.gregorian,
    this.timezone = 'UTC',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      fullName: json['fullName'],
      preferredCalendar: CalendarType.fromValue(json['preferredCalendar'] ?? 'GREGORIAN'),
      timezone: json['timezone'] ?? 'UTC',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'preferredCalendar': preferredCalendar.value,
      'timezone': timezone,
    };
  }
}
