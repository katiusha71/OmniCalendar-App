import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:shamsi_date/shamsi_date.dart';
import 'package:hijri/hijri_calendar.dart';
import '../constants/app_constants.dart';
import '../../models/event.dart';
import 'calendar_conversion_service.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'omni_calendar.db');

    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        calendarType TEXT NOT NULL,
        originalDay INTEGER NOT NULL,
        originalMonth INTEGER NOT NULL,
        originalYear INTEGER,
        isAnnualRecurring INTEGER NOT NULL DEFAULT 1,
        notifyDaysBefore INTEGER NOT NULL DEFAULT 0,
        notifyTime TEXT NOT NULL DEFAULT '09:00:00',
        gregorianDay INTEGER,
        gregorianMonth INTEGER,
        gregorianYear INTEGER,
        solarHijriDay INTEGER,
        solarHijriMonth INTEGER,
        solarHijriYear INTEGER,
        lunarHijriDay INTEGER,
        lunarHijriMonth INTEGER,
        lunarHijriYear INTEGER,
        nextDateGregorian TEXT,
        nextDateSolarHijri TEXT,
        nextDateLunarHijri TEXT,
        earliestNextDate TEXT,
        isPreloaded INTEGER NOT NULL DEFAULT 0,
        category TEXT DEFAULT 'personal',
        isHoliday INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    await _seedHolidays(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE events ADD COLUMN gregorianDay INTEGER');
      await db.execute('ALTER TABLE events ADD COLUMN gregorianMonth INTEGER');
      await db.execute('ALTER TABLE events ADD COLUMN gregorianYear INTEGER');
      await db.execute('ALTER TABLE events ADD COLUMN solarHijriDay INTEGER');
      await db.execute('ALTER TABLE events ADD COLUMN solarHijriMonth INTEGER');
      await db.execute('ALTER TABLE events ADD COLUMN solarHijriYear INTEGER');
      await db.execute('ALTER TABLE events ADD COLUMN lunarHijriDay INTEGER');
      await db.execute('ALTER TABLE events ADD COLUMN lunarHijriMonth INTEGER');
      await db.execute('ALTER TABLE events ADD COLUMN lunarHijriYear INTEGER');
      await db.execute('ALTER TABLE events ADD COLUMN nextDateGregorian TEXT');
      await db.execute('ALTER TABLE events ADD COLUMN nextDateSolarHijri TEXT');
      await db.execute('ALTER TABLE events ADD COLUMN nextDateLunarHijri TEXT');
      await db.execute('ALTER TABLE events ADD COLUMN earliestNextDate TEXT');

      final rows = await db.query('events');
      for (final row in rows) {
        final id = row['id'] as int;
        final calType = CalendarType.fromValue(row['calendarType'] as String);
        final day = row['originalDay'] as int;
        final month = row['originalMonth'] as int;
        final year = row['originalYear'] as int?;
        final isRecurring = (row['isAnnualRecurring'] as int) == 1;

        try {
          final tri = CalendarConversionService.convertToAll(
            sourceType: calType,
            day: day,
            month: month,
            year: year,
          );

          final nextDates = _computeAllNextDates(
            tri: tri,
            isAnnualRecurring: isRecurring,
            originalYear: year,
            sourceType: calType,
          );

          await db.update('events', {
            'gregorianDay': tri.gregorianDay,
            'gregorianMonth': tri.gregorianMonth,
            'gregorianYear': tri.gregorianYear,
            'solarHijriDay': tri.solarHijriDay,
            'solarHijriMonth': tri.solarHijriMonth,
            'solarHijriYear': tri.solarHijriYear,
            'lunarHijriDay': tri.lunarHijriDay,
            'lunarHijriMonth': tri.lunarHijriMonth,
            'lunarHijriYear': tri.lunarHijriYear,
            ...nextDates,
          }, where: 'id = ?', whereArgs: [id]);
        } catch (e) {
          debugPrint('Migration error for event $id: $e');
        }
      }
    }
    if (oldVersion < 3) {
      await db.execute(
        'ALTER TABLE events ADD COLUMN isPreloaded INTEGER NOT NULL DEFAULT 0',
      );
      await _seedHolidays(db);
    }
    if (oldVersion < 4) {
      await db.execute(
        "ALTER TABLE events ADD COLUMN category TEXT DEFAULT 'personal'",
      );
      await db.execute(
        'ALTER TABLE events ADD COLUMN isHoliday INTEGER DEFAULT 0',
      );
      // Backfill existing preloaded events with correct categories
      for (final holiday in AppConstants.persianHolidays) {
        final cat = holiday['category'] as String;
        final isHol = (holiday['isHoliday'] == true) ? 1 : 0;
        await db.update(
          'events',
          {'category': cat, 'isHoliday': isHol},
          where: 'title = ? AND isPreloaded = 1',
          whereArgs: [holiday['title']],
        );
      }
      // Seed new holidays that don't exist yet
      await _seedHolidays(db);
    }
  }

  Future<void> _seedHolidays(Database db) async {
    final now = DateTime.now().toIso8601String();

    for (final holiday in AppConstants.persianHolidays) {
      final calType = CalendarType.fromValue(holiday['calendarType'] as String);
      final day = holiday['day'] as int;
      final month = holiday['month'] as int;
      final year = holiday['year'] as int;
      final category = holiday['category'] as String? ?? 'national';
      final isHoliday = (holiday['isHoliday'] == true) ? 1 : 0;

      // Duplicate check
      final existing = await db.query(
        'events',
        where: 'title = ? AND originalDay = ? AND originalMonth = ? AND calendarType = ?',
        whereArgs: [holiday['title'], day, month, holiday['calendarType']],
      );
      if (existing.isNotEmpty) continue;

      try {
        final tri = CalendarConversionService.convertToAll(
          sourceType: calType,
          day: day,
          month: month,
          year: year,
        );

        final nextDates = _computeAllNextDates(
          tri: tri,
          isAnnualRecurring: true,
          originalYear: year,
          sourceType: calType,
        );

        await db.insert('events', {
          'title': holiday['title'] as String,
          'description': null,
          'calendarType': holiday['calendarType'] as String,
          'originalDay': day,
          'originalMonth': month,
          'originalYear': year,
          'isAnnualRecurring': 1,
          'notifyDaysBefore': 0,
          'notifyTime': '09:00:00',
          'gregorianDay': tri.gregorianDay,
          'gregorianMonth': tri.gregorianMonth,
          'gregorianYear': tri.gregorianYear,
          'solarHijriDay': tri.solarHijriDay,
          'solarHijriMonth': tri.solarHijriMonth,
          'solarHijriYear': tri.solarHijriYear,
          'lunarHijriDay': tri.lunarHijriDay,
          'lunarHijriMonth': tri.lunarHijriMonth,
          'lunarHijriYear': tri.lunarHijriYear,
          ...nextDates,
          'isPreloaded': 1,
          'category': category,
          'isHoliday': isHoliday,
          'createdAt': now,
          'updatedAt': now,
        });
      } catch (e) {
        debugPrint('Failed to seed holiday "${holiday['title']}": $e');
      }
    }
  }

  Map<String, String?> _computeAllNextDates({
    required TriCalendarDate tri,
    required bool isAnnualRecurring,
    required int? originalYear,
    required CalendarType sourceType,
  }) {
    final nextGreg = _nextGregorianForGregorian(
      tri.gregorianDay, tri.gregorianMonth,
      isAnnualRecurring ? null : tri.gregorianYear, isAnnualRecurring,
    );
    final nextSolar = _nextGregorianForSolarHijri(
      tri.solarHijriDay, tri.solarHijriMonth,
      isAnnualRecurring ? null : tri.solarHijriYear, isAnnualRecurring,
    );
    final nextLunar = _nextGregorianForLunarHijri(
      tri.lunarHijriDay, tri.lunarHijriMonth,
      isAnnualRecurring ? null : tri.lunarHijriYear, isAnnualRecurring,
    );

    DateTime? earliest;
    for (final d in [nextGreg, nextSolar, nextLunar]) {
      if (d != null && (earliest == null || d.isBefore(earliest))) {
        earliest = d;
      }
    }

    return {
      'nextDateGregorian': nextGreg?.toIso8601String(),
      'nextDateSolarHijri': nextSolar?.toIso8601String(),
      'nextDateLunarHijri': nextLunar?.toIso8601String(),
      'earliestNextDate': earliest?.toIso8601String(),
    };
  }

  DateTime? _nextGregorianForGregorian(int day, int month, int? year, bool isAnnualRecurring) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (!isAnnualRecurring && year != null) {
      return DateTime(year, month, day);
    }

    var candidate = DateTime(today.year, month, day);
    if (candidate.isBefore(today)) {
      candidate = DateTime(today.year + 1, month, day);
    }
    return candidate;
  }

  DateTime? _nextGregorianForSolarHijri(int day, int month, int? year, bool isAnnualRecurring) {
    final now = DateTime.now();
    final todayJalali = Jalali.fromDateTime(now);

    if (!isAnnualRecurring && year != null) {
      final jalali = Jalali(year, month, day);
      final greg = jalali.toGregorian();
      return DateTime(greg.year, greg.month, greg.day);
    }

    var candidateJalali = Jalali(todayJalali.year, month, day);
    var greg = candidateJalali.toGregorian();
    var candidateDate = DateTime(greg.year, greg.month, greg.day);
    final today = DateTime(now.year, now.month, now.day);

    if (candidateDate.isBefore(today)) {
      candidateJalali = Jalali(todayJalali.year + 1, month, day);
      greg = candidateJalali.toGregorian();
      candidateDate = DateTime(greg.year, greg.month, greg.day);
    }
    return candidateDate;
  }

  DateTime? _nextGregorianForLunarHijri(int day, int month, int? year, bool isAnnualRecurring) {
    if (!isAnnualRecurring && year != null) {
      final hijri = HijriCalendar()
        ..hYear = year
        ..hMonth = month
        ..hDay = day;
      return hijri.hijriToGregorian(year, month, day);
    }

    final nowHijri = HijriCalendar.now();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    var candidateDate = HijriCalendar()
      .hijriToGregorian(nowHijri.hYear, month, day);

    if (candidateDate.isBefore(today)) {
      candidateDate = HijriCalendar()
        .hijriToGregorian(nowHijri.hYear + 1, month, day);
    }
    return candidateDate;
  }

  Future<int> insertEvent(Event event) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final tri = CalendarConversionService.convertToAll(
      sourceType: event.calendarType,
      day: event.originalDay,
      month: event.originalMonth,
      year: event.originalYear,
    );

    final nextDates = _computeAllNextDates(
      tri: tri,
      isAnnualRecurring: event.isAnnualRecurring,
      originalYear: event.originalYear,
      sourceType: event.calendarType,
    );

    final map = {
      'title': event.title,
      'description': event.description,
      'calendarType': event.calendarType.value,
      'originalDay': event.originalDay,
      'originalMonth': event.originalMonth,
      'originalYear': event.originalYear,
      'isAnnualRecurring': event.isAnnualRecurring ? 1 : 0,
      'notifyDaysBefore': event.notifyDaysBefore,
      'notifyTime': event.notifyTime,
      'isPreloaded': event.isPreloaded ? 1 : 0,
      'category': event.category.value,
      'isHoliday': event.isHoliday ? 1 : 0,
      'gregorianDay': tri.gregorianDay,
      'gregorianMonth': tri.gregorianMonth,
      'gregorianYear': tri.gregorianYear,
      'solarHijriDay': tri.solarHijriDay,
      'solarHijriMonth': tri.solarHijriMonth,
      'solarHijriYear': tri.solarHijriYear,
      'lunarHijriDay': tri.lunarHijriDay,
      'lunarHijriMonth': tri.lunarHijriMonth,
      'lunarHijriYear': tri.lunarHijriYear,
      ...nextDates,
      'createdAt': now,
      'updatedAt': now,
    };

    return await db.insert('events', map);
  }

  Future<int> updateEvent(int id, Event event) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final tri = CalendarConversionService.convertToAll(
      sourceType: event.calendarType,
      day: event.originalDay,
      month: event.originalMonth,
      year: event.originalYear,
    );

    final nextDates = _computeAllNextDates(
      tri: tri,
      isAnnualRecurring: event.isAnnualRecurring,
      originalYear: event.originalYear,
      sourceType: event.calendarType,
    );

    final map = {
      'title': event.title,
      'description': event.description,
      'calendarType': event.calendarType.value,
      'originalDay': event.originalDay,
      'originalMonth': event.originalMonth,
      'originalYear': event.originalYear,
      'isAnnualRecurring': event.isAnnualRecurring ? 1 : 0,
      'notifyDaysBefore': event.notifyDaysBefore,
      'notifyTime': event.notifyTime,
      'isPreloaded': event.isPreloaded ? 1 : 0,
      'category': event.category.value,
      'isHoliday': event.isHoliday ? 1 : 0,
      'gregorianDay': tri.gregorianDay,
      'gregorianMonth': tri.gregorianMonth,
      'gregorianYear': tri.gregorianYear,
      'solarHijriDay': tri.solarHijriDay,
      'solarHijriMonth': tri.solarHijriMonth,
      'solarHijriYear': tri.solarHijriYear,
      'lunarHijriDay': tri.lunarHijriDay,
      'lunarHijriMonth': tri.lunarHijriMonth,
      'lunarHijriYear': tri.lunarHijriYear,
      ...nextDates,
      'updatedAt': now,
    };

    return await db.update('events', map, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteEvent(int id) async {
    final db = await database;
    return await db.delete('events', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Event>> getAllEvents() async {
    final db = await database;
    final maps = await db.query('events', orderBy: 'earliestNextDate ASC');
    return maps.map((map) => _eventFromMap(map)).toList();
  }

  Future<List<Event>> getUpcomingEvents({int days = 30}) async {
    final db = await database;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day).toIso8601String();
    final futureDate = DateTime(now.year, now.month, now.day + days).toIso8601String();

    final maps = await db.query(
      'events',
      where: 'earliestNextDate >= ? AND earliestNextDate <= ?',
      whereArgs: [today, futureDate],
      orderBy: 'earliestNextDate ASC',
    );
    return maps.map((map) => _eventFromMap(map)).toList();
  }

  Future<List<Event>> getEventsForMonth({
    required CalendarType calendarType,
    required int month,
    required int year,
  }) async {
    final db = await database;
    String dayCol, monthCol, yearCol;
    switch (calendarType) {
      case CalendarType.gregorian:
        dayCol = 'gregorianDay';
        monthCol = 'gregorianMonth';
        yearCol = 'gregorianYear';
        break;
      case CalendarType.solarHijri:
        dayCol = 'solarHijriDay';
        monthCol = 'solarHijriMonth';
        yearCol = 'solarHijriYear';
        break;
      case CalendarType.lunarHijri:
        dayCol = 'lunarHijriDay';
        monthCol = 'lunarHijriMonth';
        yearCol = 'lunarHijriYear';
        break;
    }

    final maps = await db.query(
      'events',
      where: '$monthCol = ? AND ($yearCol = ? OR isAnnualRecurring = 1)',
      whereArgs: [month, year],
      orderBy: '$dayCol ASC',
    );
    return maps.map((map) => _eventFromMap(map)).toList();
  }

  Event _eventFromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String?,
      calendarType: CalendarType.fromValue(map['calendarType'] as String),
      originalDay: map['originalDay'] as int,
      originalMonth: map['originalMonth'] as int,
      originalYear: map['originalYear'] as int?,
      isAnnualRecurring: (map['isAnnualRecurring'] as int) == 1,
      notifyDaysBefore: map['notifyDaysBefore'] as int,
      notifyTime: map['notifyTime'] as String,
      isPreloaded: (map['isPreloaded'] as int?) == 1,
      category: map['category'] != null
          ? EventCategory.fromValue(map['category'] as String)
          : EventCategory.personal,
      isHoliday: (map['isHoliday'] as int?) == 1,
      gregorianDay: map['gregorianDay'] as int?,
      gregorianMonth: map['gregorianMonth'] as int?,
      gregorianYear: map['gregorianYear'] as int?,
      solarHijriDay: map['solarHijriDay'] as int?,
      solarHijriMonth: map['solarHijriMonth'] as int?,
      solarHijriYear: map['solarHijriYear'] as int?,
      lunarHijriDay: map['lunarHijriDay'] as int?,
      lunarHijriMonth: map['lunarHijriMonth'] as int?,
      lunarHijriYear: map['lunarHijriYear'] as int?,
      nextDateGregorian: map['nextDateGregorian'] != null
          ? DateTime.parse(map['nextDateGregorian'] as String)
          : null,
      nextDateSolarHijri: map['nextDateSolarHijri'] != null
          ? DateTime.parse(map['nextDateSolarHijri'] as String)
          : null,
      nextDateLunarHijri: map['nextDateLunarHijri'] != null
          ? DateTime.parse(map['nextDateLunarHijri'] as String)
          : null,
      earliestNextDate: map['earliestNextDate'] != null
          ? DateTime.parse(map['earliestNextDate'] as String)
          : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
