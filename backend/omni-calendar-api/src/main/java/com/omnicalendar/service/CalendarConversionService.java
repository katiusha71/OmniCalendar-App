package com.omnicalendar.service;

import com.omnicalendar.dto.response.ConvertedDateResponse;
import com.omnicalendar.model.enums.CalendarType;
import lombok.extern.slf4j.Slf4j;
import net.time4j.PlainDate;
import net.time4j.calendar.HijriCalendar;
import net.time4j.calendar.PersianCalendar;
import net.time4j.engine.CalendarDate;
import net.time4j.format.expert.ChronoFormatter;
import net.time4j.format.expert.PatternType;
import org.springframework.stereotype.Service;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.format.TextStyle;
import java.util.Locale;

@Service
@Slf4j
public class CalendarConversionService {

    private static final String[] PERSIAN_MONTHS = {
            "Farvardin", "Ordibehesht", "Khordad", "Tir", "Mordad", "Shahrivar",
            "Mehr", "Aban", "Azar", "Dey", "Bahman", "Esfand"
    };

    private static final String[] HIJRI_MONTHS = {
            "Muharram", "Safar", "Rabi' al-Awwal", "Rabi' al-Thani",
            "Jumada al-Awwal", "Jumada al-Thani", "Rajab", "Sha'ban",
            "Ramadan", "Shawwal", "Dhu al-Qi'dah", "Dhu al-Hijjah"
    };

    private static final String[] GREGORIAN_MONTHS = {
            "January", "February", "March", "April", "May", "June",
            "July", "August", "September", "October", "November", "December"
    };

    public ConvertedDateResponse convert(int day, int month, Integer year,
                                         CalendarType sourceType, CalendarType targetType) {
        LocalDate gregorianDate;
        int sourceYear;

        if (year == null) {
            sourceYear = getCurrentYearInCalendar(sourceType);
        } else {
            sourceYear = year;
        }

        gregorianDate = convertToGregorian(day, month, sourceYear, sourceType);

        ConvertedDateResponse.DateInfo sourceInfo = buildDateInfo(day, month, sourceYear, sourceType, gregorianDate);
        ConvertedDateResponse.DateInfo targetInfo;

        if (targetType == CalendarType.GREGORIAN) {
            targetInfo = buildGregorianDateInfo(gregorianDate);
        } else {
            int[] targetDate = convertFromGregorian(gregorianDate, targetType);
            targetInfo = buildDateInfo(targetDate[0], targetDate[1], targetDate[2], targetType, gregorianDate);
        }

        return ConvertedDateResponse.builder()
                .sourceCalendar(sourceType)
                .targetCalendar(targetType)
                .sourceDate(sourceInfo)
                .targetDate(targetInfo)
                .build();
    }

    public LocalDate convertToGregorian(int day, int month, Integer year, CalendarType type) {
        if (type == CalendarType.GREGORIAN) {
            int gregorianYear = year != null ? year : LocalDate.now().getYear();
            return LocalDate.of(gregorianYear, month, day);
        }

        int calendarYear = year != null ? year : getCurrentYearInCalendar(type);

        try {
            if (type == CalendarType.SOLAR_HIJRI) {
                PersianCalendar persian = PersianCalendar.of(calendarYear, month, day);
                PlainDate plainDate = persian.transform(PlainDate.axis());
                return LocalDate.of(plainDate.getYear(), plainDate.getMonth(), plainDate.getDayOfMonth());
            } else if (type == CalendarType.LUNAR_HIJRI) {
                HijriCalendar hijri = HijriCalendar.of(HijriCalendar.VARIANT_UMALQURA, calendarYear, month, day);
                PlainDate plainDate = hijri.transform(PlainDate.axis());
                return LocalDate.of(plainDate.getYear(), plainDate.getMonth(), plainDate.getDayOfMonth());
            }
        } catch (Exception e) {
            log.error("Error converting date to Gregorian: day={}, month={}, year={}, type={}",
                    day, month, year, type, e);
            throw new IllegalArgumentException("Invalid date for calendar type: " + type);
        }

        throw new IllegalArgumentException("Unsupported calendar type: " + type);
    }

    public int[] convertFromGregorian(LocalDate gregorianDate, CalendarType targetType) {
        if (targetType == CalendarType.GREGORIAN) {
            return new int[]{gregorianDate.getDayOfMonth(), gregorianDate.getMonthValue(), gregorianDate.getYear()};
        }

        PlainDate plainDate = PlainDate.of(gregorianDate.getYear(),
                gregorianDate.getMonthValue(), gregorianDate.getDayOfMonth());

        try {
            if (targetType == CalendarType.SOLAR_HIJRI) {
                PersianCalendar persian = plainDate.transform(PersianCalendar.axis());
                return new int[]{persian.getDayOfMonth(), persian.getMonth().getValue(), persian.getYear()};
            } else if (targetType == CalendarType.LUNAR_HIJRI) {
                HijriCalendar hijri = plainDate.transform(HijriCalendar.class, HijriCalendar.VARIANT_UMALQURA);
                return new int[]{hijri.getDayOfMonth(), hijri.getMonth().getValue(), hijri.getYear()};
            }
        } catch (Exception e) {
            log.error("Error converting from Gregorian: date={}, targetType={}", gregorianDate, targetType, e);
            throw new IllegalArgumentException("Error converting date to: " + targetType);
        }

        throw new IllegalArgumentException("Unsupported calendar type: " + targetType);
    }

    public LocalDate getGregorianDateForCurrentYear(int day, int month, CalendarType type) {
        int currentYear = getCurrentYearInCalendar(type);
        return convertToGregorian(day, month, currentYear, type);
    }

    public int getCurrentYearInCalendar(CalendarType type) {
        LocalDate today = LocalDate.now();

        if (type == CalendarType.GREGORIAN) {
            return today.getYear();
        }

        int[] converted = convertFromGregorian(today, type);
        return converted[2];
    }

    public ConvertedDateResponse getTodayInAllCalendars() {
        LocalDate today = LocalDate.now();

        int[] persian = convertFromGregorian(today, CalendarType.SOLAR_HIJRI);
        int[] hijri = convertFromGregorian(today, CalendarType.LUNAR_HIJRI);

        ConvertedDateResponse.DateInfo gregorianInfo = buildGregorianDateInfo(today);

        return ConvertedDateResponse.builder()
                .sourceCalendar(CalendarType.GREGORIAN)
                .targetCalendar(CalendarType.GREGORIAN)
                .sourceDate(gregorianInfo)
                .targetDate(ConvertedDateResponse.DateInfo.builder()
                        .day(persian[0])
                        .month(persian[1])
                        .year(persian[2])
                        .monthName(PERSIAN_MONTHS[persian[1] - 1])
                        .dayOfWeek(today.getDayOfWeek().getDisplayName(TextStyle.FULL, Locale.ENGLISH))
                        .formatted(String.format("%d %s %d (Solar Hijri) / %d %s %d (Lunar Hijri)",
                                persian[0], PERSIAN_MONTHS[persian[1] - 1], persian[2],
                                hijri[0], HIJRI_MONTHS[hijri[1] - 1], hijri[2]))
                        .build())
                .build();
    }

    private ConvertedDateResponse.DateInfo buildDateInfo(int day, int month, int year,
                                                          CalendarType type, LocalDate gregorianDate) {
        String monthName;
        switch (type) {
            case SOLAR_HIJRI -> monthName = PERSIAN_MONTHS[month - 1];
            case LUNAR_HIJRI -> monthName = HIJRI_MONTHS[month - 1];
            default -> monthName = GREGORIAN_MONTHS[month - 1];
        }

        String dayOfWeek = gregorianDate.getDayOfWeek().getDisplayName(TextStyle.FULL, Locale.ENGLISH);
        String formatted = String.format("%d %s %d", day, monthName, year);

        return ConvertedDateResponse.DateInfo.builder()
                .day(day)
                .month(month)
                .year(year)
                .monthName(monthName)
                .dayOfWeek(dayOfWeek)
                .formatted(formatted)
                .build();
    }

    private ConvertedDateResponse.DateInfo buildGregorianDateInfo(LocalDate date) {
        return ConvertedDateResponse.DateInfo.builder()
                .day(date.getDayOfMonth())
                .month(date.getMonthValue())
                .year(date.getYear())
                .monthName(GREGORIAN_MONTHS[date.getMonthValue() - 1])
                .dayOfWeek(date.getDayOfWeek().getDisplayName(TextStyle.FULL, Locale.ENGLISH))
                .formatted(String.format("%d %s %d", date.getDayOfMonth(),
                        GREGORIAN_MONTHS[date.getMonthValue() - 1], date.getYear()))
                .build();
    }
}
