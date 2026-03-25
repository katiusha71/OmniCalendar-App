import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/app_localizations.dart';

class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/calendar')) return 1;
    if (location.startsWith('/events')) return 2;
    if (location.startsWith('/converter')) return 3;
    return 0; // today
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(localizationProvider);
    final currentIndex = _currentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/today');
              break;
            case 1:
              context.go('/calendar');
              break;
            case 2:
              context.go('/events');
              break;
            case 3:
              context.go('/converter');
              break;
          }
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.today),
            label: l10n.get('today'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month),
            label: l10n.get('calendar'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.event),
            label: l10n.get('events'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.swap_horiz),
            label: l10n.get('converter'),
          ),
        ],
      ),
    );
  }
}
