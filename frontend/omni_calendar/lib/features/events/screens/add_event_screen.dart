import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/calendar_conversion_service.dart';
import '../../../models/event.dart';
import '../providers/events_provider.dart';

class AddEventScreen extends ConsumerStatefulWidget {
  final int? eventId;

  const AddEventScreen({super.key, this.eventId});

  @override
  ConsumerState<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends ConsumerState<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  CalendarType _calendarType = CalendarType.gregorian;
  EventCategory _category = EventCategory.personal;
  int _selectedDay = 1;
  int _selectedMonth = 1;
  int _selectedYear = DateTime.now().year;
  bool _isAnnualRecurring = true;
  int _notifyDaysBefore = 0;
  TimeOfDay _notifyTime = const TimeOfDay(hour: 9, minute: 0);

  bool _isLoading = false;
  Event? _existingEvent;

  @override
  void initState() {
    super.initState();
    if (widget.eventId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadExistingEvent();
      });
    }
  }

  void _loadExistingEvent() {
    final events = ref.read(eventsProvider).events;
    final event = events.firstWhere(
      (e) => e.id == widget.eventId,
      orElse: () => throw Exception('Event not found'),
    );

    setState(() {
      _existingEvent = event;
      _titleController.text = event.title;
      _descriptionController.text = event.description ?? '';
      _calendarType = event.calendarType;
      _category = event.category;
      _selectedDay = event.originalDay;
      _selectedMonth = event.originalMonth;
      _selectedYear = event.originalYear ?? DateTime.now().year;
      _isAnnualRecurring = event.isAnnualRecurring;
      _notifyDaysBefore = event.notifyDaysBefore;

      final timeParts = event.notifyTime.split(':');
      _notifyTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  List<String> get _currentMonths {
    switch (_calendarType) {
      case CalendarType.solarHijri:
        return AppConstants.persianMonths;
      case CalendarType.lunarHijri:
        return AppConstants.hijriMonths;
      case CalendarType.gregorian:
        return AppConstants.gregorianMonths;
    }
  }

  int get _daysInMonth {
    if (_calendarType == CalendarType.gregorian) {
      final daysPerMonth = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
      return daysPerMonth[_selectedMonth - 1];
    } else if (_calendarType == CalendarType.solarHijri) {
      if (_selectedMonth <= 6) return 31;
      if (_selectedMonth <= 11) return 30;
      return 30;
    } else {
      if (_selectedMonth == 12) return 30;
      return _selectedMonth.isOdd ? 30 : 29;
    }
  }

  TriCalendarDate? _getConvertedDates() {
    try {
      return CalendarConversionService.convertToAll(
        sourceType: _calendarType,
        day: _selectedDay,
        month: _selectedMonth,
        year: _selectedYear,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final event = Event(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      calendarType: _calendarType,
      category: _category,
      originalDay: _selectedDay,
      originalMonth: _selectedMonth,
      originalYear: _selectedYear,
      isAnnualRecurring: _isAnnualRecurring,
      notifyDaysBefore: _notifyDaysBefore,
      notifyTime:
          '${_notifyTime.hour.toString().padLeft(2, '0')}:${_notifyTime.minute.toString().padLeft(2, '0')}:00',
    );

    bool success;
    if (_existingEvent != null) {
      success = await ref
          .read(eventsProvider.notifier)
          .updateEvent(_existingEvent!.id!, event);
    } else {
      success = await ref.read(eventsProvider.notifier).createEvent(event);
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = ref.watch(localizationProvider);
    final isEditing = widget.eventId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.get('editEvent') : l10n.get('newEvent')),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleSave,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.get('save')),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: l10n.get('eventTitle'),
                prefixIcon: const Icon(Icons.title),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.get('pleaseEnterTitle');
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: l10n.get('description'),
                prefixIcon: const Icon(Icons.description),
                alignLabelWithHint: true,
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.get('category'),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: EventCategory.values.map((cat) {
                final isSelected = _category == cat;
                return ChoiceChip(
                  selected: isSelected,
                  onSelected: (_) => setState(() => _category = cat),
                  avatar: Icon(cat.icon, size: 18, color: isSelected ? theme.colorScheme.onPrimary : cat.color),
                  label: Text(l10n.get(cat.value)),
                  selectedColor: cat.color,
                  labelStyle: TextStyle(
                    color: isSelected ? theme.colorScheme.onPrimary : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.get('calendarType'),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SegmentedButton<CalendarType>(
              segments: CalendarType.values
                  .map((type) => ButtonSegment(
                        value: type,
                        label: Text(
                          type.displayName.split(' ').first,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ))
                  .toList(),
              selected: {_calendarType},
              onSelectionChanged: (selected) {
                setState(() {
                  _calendarType = selected.first;
                  if (_selectedDay > _daysInMonth) {
                    _selectedDay = _daysInMonth;
                  }
                });
              },
            ),
            const SizedBox(height: 24),
            Text(
              l10n.get('date'),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<int>(
                    value: _selectedDay,
                    decoration: InputDecoration(
                      labelText: l10n.get('day'),
                    ),
                    items: List.generate(
                      _daysInMonth,
                      (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text('${i + 1}'),
                      ),
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedDay = value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<int>(
                    value: _selectedMonth,
                    decoration: InputDecoration(
                      labelText: l10n.get('month'),
                    ),
                    items: List.generate(
                      12,
                      (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text(_currentMonths[i]),
                      ),
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedMonth = value;
                          if (_selectedDay > _daysInMonth) {
                            _selectedDay = _daysInMonth;
                          }
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCelebrationsPreview(theme, l10n),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _selectedYear.toString(),
              decoration: InputDecoration(
                labelText: l10n.get('year'),
                prefixIcon: const Icon(Icons.calendar_today),
                helperText: _isAnnualRecurring
                    ? l10n.get('usedForConversion')
                    : null,
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.get('pleaseEnterYear');
                }
                final year = int.tryParse(value);
                if (year == null || year < 1 || year > 9999) {
                  return l10n.get('invalidYear');
                }
                return null;
              },
              onChanged: (value) {
                final parsed = int.tryParse(value);
                if (parsed != null) {
                  setState(() => _selectedYear = parsed);
                }
              },
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: Text(l10n.get('annualRecurring')),
              subtitle: Text(l10n.get('annualRecurringDesc')),
              value: _isAnnualRecurring,
              onChanged: (value) {
                setState(() {
                  _isAnnualRecurring = value;
                });
              },
            ),
            const SizedBox(height: 24),
            Text(
              l10n.get('notification'),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _notifyDaysBefore,
              decoration: InputDecoration(
                labelText: l10n.get('notifyBefore'),
                prefixIcon: const Icon(Icons.notifications_outlined),
              ),
              items: [
                DropdownMenuItem(value: 0, child: Text(l10n.get('onTheDay'))),
                DropdownMenuItem(value: 1, child: Text(l10n.get('dayBefore'))),
                DropdownMenuItem(value: 2, child: Text(l10n.get('daysBefore2'))),
                DropdownMenuItem(value: 3, child: Text(l10n.get('daysBefore3'))),
                DropdownMenuItem(value: 7, child: Text(l10n.get('weekBefore'))),
                DropdownMenuItem(value: 14, child: Text(l10n.get('weeksBefore2'))),
                DropdownMenuItem(value: 30, child: Text(l10n.get('monthBefore'))),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _notifyDaysBefore = value);
                }
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: Text(l10n.get('notificationTime')),
              subtitle: Text(_notifyTime.format(context)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _notifyTime,
                );
                if (time != null) {
                  setState(() => _notifyTime = time);
                }
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCelebrationsPreview(ThemeData theme, AppLocalizations l10n) {
    final tri = _getConvertedDates();
    if (tri == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.celebration_outlined,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                l10n.get('celebrationsInAll'),
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildPreviewRow(
            theme, l10n,
            Icons.calendar_month,
            const Color(0xFF4285F4),
            l10n.get('gregorian'),
            tri.formattedGregorian(),
            _calendarType == CalendarType.gregorian,
          ),
          const SizedBox(height: 6),
          _buildPreviewRow(
            theme, l10n,
            Icons.wb_sunny_outlined,
            const Color(0xFF34A853),
            l10n.get('solarHijri'),
            tri.formattedSolarHijri(),
            _calendarType == CalendarType.solarHijri,
          ),
          const SizedBox(height: 6),
          _buildPreviewRow(
            theme, l10n,
            Icons.nightlight_outlined,
            const Color(0xFF9C27B0),
            l10n.get('lunarHijri'),
            tri.formattedLunarHijri(),
            _calendarType == CalendarType.lunarHijri,
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewRow(
    ThemeData theme,
    AppLocalizations l10n,
    IconData icon,
    Color color,
    String label,
    String date,
    bool isPrimary,
  ) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            date,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
        if (isPrimary)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              l10n.get('source'),
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontSize: 10,
              ),
            ),
          ),
      ],
    );
  }
}
