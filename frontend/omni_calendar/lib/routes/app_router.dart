import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/today/screens/today_screen.dart';
import '../features/calendar/screens/calendar_screen.dart';
import '../features/events/screens/events_list_screen.dart';
import '../features/events/screens/add_event_screen.dart';
import '../features/converter/screens/converter_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../shared/widgets/main_shell.dart';

final _shellNavigatorKey = GlobalKey<NavigatorState>();
final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/today',
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/today',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TodayScreen(),
            ),
          ),
          GoRoute(
            path: '/calendar',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CalendarScreen(),
            ),
          ),
          GoRoute(
            path: '/events',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: EventsListScreen(),
            ),
          ),
          GoRoute(
            path: '/converter',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ConverterScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/add-event',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddEventScreen(),
      ),
      GoRoute(
        path: '/edit-event/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final eventId = int.parse(state.pathParameters['id']!);
          return AddEventScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
