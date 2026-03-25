package com.omnicalendar.dto.response;

import com.omnicalendar.model.enums.CalendarType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EventResponse {

    private Long id;
    private String title;
    private String description;
    private CalendarType calendarType;
    private Integer originalDay;
    private Integer originalMonth;
    private Integer originalYear;
    private Boolean isAnnualRecurring;
    private Integer notifyDaysBefore;
    private LocalTime notifyTime;
    private LocalDate nextGregorianDate;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
