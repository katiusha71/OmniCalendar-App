import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class CalendarTypeChip extends StatelessWidget {
  final CalendarType type;
  final bool isSelected;
  final VoidCallback? onTap;

  const CalendarTypeChip({
    super.key,
    required this.type,
    this.isSelected = false,
    this.onTap,
  });

  Color _getColor() {
    switch (type) {
      case CalendarType.gregorian:
        return const Color(0xFF4285F4);
      case CalendarType.solarHijri:
        return const Color(0xFF34A853);
      case CalendarType.lunarHijri:
        return const Color(0xFF9C27B0);
    }
  }

  IconData _getIcon() {
    switch (type) {
      case CalendarType.gregorian:
        return Icons.calendar_month;
      case CalendarType.solarHijri:
        return Icons.wb_sunny_outlined;
      case CalendarType.lunarHijri:
        return Icons.nightlight_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final theme = Theme.of(context);

    return FilterChip(
      selected: isSelected,
      onSelected: onTap != null ? (_) => onTap!() : null,
      avatar: Icon(
        _getIcon(),
        size: 18,
        color: isSelected ? theme.colorScheme.onPrimary : color,
      ),
      label: Text(type.displayName),
      selectedColor: color,
      checkmarkColor: theme.colorScheme.onPrimary,
      labelStyle: TextStyle(
        color: isSelected ? theme.colorScheme.onPrimary : null,
      ),
    );
  }
}
