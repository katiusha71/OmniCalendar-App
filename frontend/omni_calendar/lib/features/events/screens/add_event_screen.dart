import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
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
  int _selectedDay = 1;
  int _selectedMonth = 1;
  int? _selectedYear;
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
      _selectedDay = event.originalDay;
      _selectedMonth = event.originalMonth;
      _selectedYear = event.originalYear;
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

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final event = Event(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      calendarType: _calendarType,
      originalDay: _selectedDay,
      originalMonth: _selectedMonth,
      originalYear: _isAnnualRecurring ? null : _selectedYear,
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
    final isEditing = widget.eventId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Event' : 'New Event'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleSave,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
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
              decoration: const InputDecoration(
                labelText: 'Event Title',
                prefixIcon: Icon(Icons.title),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Text(
              'Calendar Type',
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
              'Date',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<int>(
                    value: _selectedDay,
                    decoration: const InputDecoration(
                      labelText: 'Day',
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
                    decoration: const InputDecoration(
                      labelText: 'Month',
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
            SwitchListTile(
              title: const Text('Annual Recurring'),
              subtitle: const Text('Repeat every year on this date'),
              value: _isAnnualRecurring,
              onChanged: (value) {
                setState(() {
                  _isAnnualRecurring = value;
                  if (!value && _selectedYear == null) {
                    _selectedYear = DateTime.now().year;
                  }
                });
              },
            ),
            if (!_isAnnualRecurring) ...[
              const SizedBox(height: 8),
              TextFormField(
                initialValue: _selectedYear?.toString() ?? '',
                decoration: const InputDecoration(
                  labelText: 'Year',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (!_isAnnualRecurring) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a year';
                    }
                    final year = int.tryParse(value);
                    if (year == null || year < 1 || year > 9999) {
                      return 'Please enter a valid year';
                    }
                  }
                  return null;
                },
                onChanged: (value) {
                  _selectedYear = int.tryParse(value);
                },
              ),
            ],
            const SizedBox(height: 24),
            Text(
              'Notification',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _notifyDaysBefore,
              decoration: const InputDecoration(
                labelText: 'Notify before',
                prefixIcon: Icon(Icons.notifications_outlined),
              ),
              items: const [
                DropdownMenuItem(value: 0, child: Text('On the day')),
                DropdownMenuItem(value: 1, child: Text('1 day before')),
                DropdownMenuItem(value: 2, child: Text('2 days before')),
                DropdownMenuItem(value: 3, child: Text('3 days before')),
                DropdownMenuItem(value: 7, child: Text('1 week before')),
                DropdownMenuItem(value: 14, child: Text('2 weeks before')),
                DropdownMenuItem(value: 30, child: Text('1 month before')),
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
              title: const Text('Notification Time'),
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
}
