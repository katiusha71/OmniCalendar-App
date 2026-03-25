package com.omnicalendar.controller;

import com.omnicalendar.dto.request.ConvertDateRequest;
import com.omnicalendar.dto.response.ApiResponse;
import com.omnicalendar.dto.response.ConvertedDateResponse;
import com.omnicalendar.model.enums.CalendarType;
import com.omnicalendar.service.CalendarConversionService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/calendar")
@RequiredArgsConstructor
public class CalendarController {

    private final CalendarConversionService calendarService;

    @PostMapping("/convert")
    public ResponseEntity<ApiResponse<ConvertedDateResponse>> convertDate(
            @Valid @RequestBody ConvertDateRequest request) {
        ConvertedDateResponse response = calendarService.convert(
                request.getDay(),
                request.getMonth(),
                request.getYear(),
                request.getCalendarType(),
                request.getTargetType()
        );
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @GetMapping("/today")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getTodayInAllCalendars() {
        LocalDate today = LocalDate.now();

        int[] persian = calendarService.convertFromGregorian(today, CalendarType.SOLAR_HIJRI);
        int[] hijri = calendarService.convertFromGregorian(today, CalendarType.LUNAR_HIJRI);

        Map<String, Object> result = new HashMap<>();

        Map<String, Object> gregorian = new HashMap<>();
        gregorian.put("day", today.getDayOfMonth());
        gregorian.put("month", today.getMonthValue());
        gregorian.put("year", today.getYear());
        gregorian.put("formatted", String.format("%d/%d/%d", today.getMonthValue(),
                today.getDayOfMonth(), today.getYear()));
        result.put("gregorian", gregorian);

        Map<String, Object> solarHijri = new HashMap<>();
        solarHijri.put("day", persian[0]);
        solarHijri.put("month", persian[1]);
        solarHijri.put("year", persian[2]);
        solarHijri.put("formatted", String.format("%d/%d/%d", persian[2], persian[1], persian[0]));
        result.put("solarHijri", solarHijri);

        Map<String, Object> lunarHijri = new HashMap<>();
        lunarHijri.put("day", hijri[0]);
        lunarHijri.put("month", hijri[1]);
        lunarHijri.put("year", hijri[2]);
        lunarHijri.put("formatted", String.format("%d/%d/%d", hijri[2], hijri[1], hijri[0]));
        result.put("lunarHijri", lunarHijri);

        return ResponseEntity.ok(ApiResponse.success(result));
    }
}
