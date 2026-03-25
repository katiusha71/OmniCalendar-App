import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/event.dart';

class IcsExportService {
  static String generateIcs(Event event) {
    final buf = StringBuffer();
    buf.writeln('BEGIN:VCALENDAR');
    buf.writeln('VERSION:2.0');
    buf.writeln('PRODID:-//OmniCalendar//EN');
    buf.writeln('BEGIN:VEVENT');

    // Use Gregorian date for DTSTART
    if (event.gregorianYear != null &&
        event.gregorianMonth != null &&
        event.gregorianDay != null) {
      final y = event.gregorianYear.toString().padLeft(4, '0');
      final m = event.gregorianMonth.toString().padLeft(2, '0');
      final d = event.gregorianDay.toString().padLeft(2, '0');
      buf.writeln('DTSTART;VALUE=DATE:$y$m$d');
      buf.writeln('DTEND;VALUE=DATE:$y$m$d');
    }

    buf.writeln('SUMMARY:${_escapeIcs(event.title)}');

    if (event.description != null && event.description!.isNotEmpty) {
      buf.writeln('DESCRIPTION:${_escapeIcs(event.description!)}');
    }

    if (event.isAnnualRecurring) {
      buf.writeln('RRULE:FREQ=YEARLY');
    }

    buf.writeln('END:VEVENT');
    buf.writeln('END:VCALENDAR');
    return buf.toString();
  }

  static String generateIcsMultiple(List<Event> events) {
    final buf = StringBuffer();
    buf.writeln('BEGIN:VCALENDAR');
    buf.writeln('VERSION:2.0');
    buf.writeln('PRODID:-//OmniCalendar//EN');

    for (final event in events) {
      buf.writeln('BEGIN:VEVENT');

      if (event.gregorianYear != null &&
          event.gregorianMonth != null &&
          event.gregorianDay != null) {
        final y = event.gregorianYear.toString().padLeft(4, '0');
        final m = event.gregorianMonth.toString().padLeft(2, '0');
        final d = event.gregorianDay.toString().padLeft(2, '0');
        buf.writeln('DTSTART;VALUE=DATE:$y$m$d');
        buf.writeln('DTEND;VALUE=DATE:$y$m$d');
      }

      buf.writeln('SUMMARY:${_escapeIcs(event.title)}');

      if (event.description != null && event.description!.isNotEmpty) {
        buf.writeln('DESCRIPTION:${_escapeIcs(event.description!)}');
      }

      if (event.isAnnualRecurring) {
        buf.writeln('RRULE:FREQ=YEARLY');
      }

      buf.writeln('END:VEVENT');
    }

    buf.writeln('END:VCALENDAR');
    return buf.toString();
  }

  static Future<void> shareEvent(Event event) async {
    if (kIsWeb) {
      debugPrint('ICS export not supported on web');
      return;
    }
    try {
      final ics = generateIcs(event);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${_sanitizeFilename(event.title)}.ics');
      await file.writeAsString(ics);
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: event.title,
      );
    } catch (e) {
      debugPrint('Failed to share event: $e');
    }
  }

  static Future<void> shareMultipleEvents(List<Event> events) async {
    if (kIsWeb || events.isEmpty) return;
    try {
      final ics = generateIcsMultiple(events);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/omni_calendar_events.ics');
      await file.writeAsString(ics);
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'OmniCalendar Events',
      );
    } catch (e) {
      debugPrint('Failed to share events: $e');
    }
  }

  static String _escapeIcs(String text) {
    return text
        .replaceAll('\\', '\\\\')
        .replaceAll(';', '\\;')
        .replaceAll(',', '\\,')
        .replaceAll('\n', '\\n');
  }

  static String _sanitizeFilename(String name) {
    return name
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
  }
}
