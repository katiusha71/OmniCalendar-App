# OmniCalendar

A cross-platform calendar application with multi-calendar system support. Create and manage events in Gregorian, Solar Hijri (Persian), and Lunar Hijri (Islamic) calendars with automatic date conversion and push notifications.

## Features

- **Multi-Calendar Support**: Work with three calendar systems simultaneously
  - Gregorian (Western)
  - Solar Hijri / Shamsi (Persian/Iranian)
  - Lunar Hijri (Islamic)
- **Automatic Date Conversion**: Convert dates between all supported calendar systems
- **Event Management**: Create, edit, and delete events with custom notifications
- **Annual Recurring Events**: Set events to repeat yearly (birthdays, anniversaries)
- **Push Notifications**: Get reminded before events via Firebase Cloud Messaging
- **Cross-Platform**: Web and mobile support via Flutter
- **Secure Authentication**: JWT-based authentication with refresh tokens

## Tech Stack

### Backend
| Technology | Version | Purpose |
|------------|---------|---------|
| Java | 17 | Runtime |
| Spring Boot | 3.2.0 | Framework |
| Spring Security | 6.x | Authentication & Authorization |
| Spring Data JPA | 3.x | Database ORM |
| MySQL | 8.0+ | Database |
| JWT (jjwt) | 0.12.3 | Token-based auth |
| Time4J | 5.9.3 | Calendar conversions |
| Firebase Admin SDK | 9.2.0 | Push notifications |
| Lombok | - | Boilerplate reduction |

### Frontend
| Technology | Version | Purpose |
|------------|---------|---------|
| Flutter | 3.x | UI Framework |
| Dart | >=3.0.0 | Language |
| Riverpod | 2.4.9 | State Management |
| Dio | 5.4.0 | HTTP Client |
| go_router | 13.0.1 | Navigation |
| shamsi_date | 1.0.2 | Persian calendar |
| hijri | 3.0.0 | Islamic calendar |
| flutter_secure_storage | 9.0.0 | Secure token storage |

## Project Structure

```
OmniCalendar/
├── backend/
│   └── omni-calendar-api/
│       ├── src/main/java/com/omnicalendar/
│       │   ├── config/           # Security, Firebase configs
│       │   ├── controller/       # REST API endpoints
│       │   ├── dto/              # Request/Response objects
│       │   ├── exception/        # Global exception handling
│       │   ├── model/            # JPA entities
│       │   ├── repository/       # Data access layer
│       │   ├── security/         # JWT filter & provider
│       │   └── service/          # Business logic
│       └── pom.xml
├── frontend/
│   └── omni_calendar/
│       ├── lib/
│       │   ├── core/             # Theme, constants, services
│       │   ├── features/         # Auth, calendar, events
│       │   ├── models/           # Data models
│       │   ├── routes/           # App navigation
│       │   └── shared/           # Reusable widgets
│       └── pubspec.yaml
└── database/
    └── schema.sql                # MySQL schema
```

## API Endpoints

### Authentication
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/register` | Register new user |
| POST | `/api/auth/login` | Login and get tokens |
| POST | `/api/auth/refresh` | Refresh access token |
| PUT | `/api/auth/fcm-token` | Update FCM token for notifications |

### Events
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/events` | Get all user events |
| GET | `/api/events/{id}` | Get event by ID |
| POST | `/api/events` | Create new event |
| PUT | `/api/events/{id}` | Update event |
| DELETE | `/api/events/{id}` | Delete event |
| GET | `/api/events/upcoming?days=30` | Get upcoming events |

### Calendar
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/calendar/convert` | Convert date between calendars |
| GET | `/api/calendar/today` | Get today's date in all calendars |

## Database Schema

```sql
-- Users: stores user accounts and preferences
users (
    id, email, password_hash, full_name,
    preferred_calendar, timezone, fcm_token,
    created_at, updated_at
)

-- Events: calendar events with multi-calendar support
events (
    id, user_id, title, description,
    calendar_type, original_day, original_month, original_year,
    is_annual_recurring, notify_days_before, notify_time,
    created_at, updated_at
)

-- Notifications: scheduled push notifications
notifications (
    id, event_id, user_id,
    scheduled_date, scheduled_time, status, sent_at,
    created_at
)
```

## Getting Started

### Prerequisites
- Java 17+
- Maven 3.8+
- MySQL 8.0+
- Flutter SDK 3.x
- Firebase project (for push notifications)

### Backend Setup

1. **Create MySQL database**
   ```bash
   mysql -u root -p < database/schema.sql
   ```

2. **Configure application**

   Edit `backend/omni-calendar-api/src/main/resources/application.yml`:
   ```yaml
   spring:
     datasource:
       url: jdbc:mysql://localhost:3306/omni_calendar
       username: your_username
       password: your_password

   jwt:
     secret: ${JWT_SECRET:your-256-bit-secret-key}

   firebase:
     config-file: ${FIREBASE_CONFIG:classpath:firebase-service-account.json}
   ```

3. **Add Firebase credentials**

   Place your `firebase-service-account.json` in `src/main/resources/`

4. **Run the backend**
   ```bash
   cd backend/omni-calendar-api
   mvn spring-boot:run
   ```

   API will be available at `http://localhost:8080`

### Frontend Setup

1. **Install dependencies**
   ```bash
   cd frontend/omni_calendar
   flutter pub get
   ```

2. **Configure API endpoint**

   Edit `lib/core/constants/api_constants.dart` with your backend URL

3. **Run the app**
   ```bash
   # Web
   flutter run -d chrome

   # Windows
   flutter run -d windows

   # Android/iOS
   flutter run
   ```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `JWT_SECRET` | Secret key for JWT signing (min 256 bits) | Development key |
| `FIREBASE_CONFIG` | Path to Firebase service account JSON | `classpath:firebase-service-account.json` |

## Calendar Systems

### Gregorian
The standard Western calendar used internationally.

### Solar Hijri (Shamsi)
The Persian/Iranian calendar based on the solar year. Used primarily in Iran and Afghanistan.
- Months: Farvardin, Ordibehesht, Khordad, Tir, Mordad, Shahrivar, Mehr, Aban, Azar, Dey, Bahman, Esfand

### Lunar Hijri (Islamic)
The Islamic calendar based on the lunar cycle. Used for Islamic religious observances worldwide.
- Months: Muharram, Safar, Rabi al-Awwal, Rabi al-Thani, Jumada al-Awwal, Jumada al-Thani, Rajab, Shaban, Ramadan, Shawwal, Dhu al-Qadah, Dhu al-Hijjah

## License

This project is private and proprietary.

## Author

[katiusha71](https://github.com/katiusha71)
