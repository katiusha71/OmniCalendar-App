package com.omnicalendar.dto.request;

import com.omnicalendar.model.enums.CalendarType;
import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class EventRequest {

    @NotBlank(message = "Title is required")
    @Size(max = 255, message = "Title must not exceed 255 characters")
    private String title;

    private String description;

    @NotNull(message = "Calendar type is required")
    private CalendarType calendarType;

    @NotNull(message = "Day is required")
    @Min(value = 1, message = "Day must be at least 1")
    @Max(value = 31, message = "Day must not exceed 31")
    private Integer originalDay;

    @NotNull(message = "Month is required")
    @Min(value = 1, message = "Month must be at least 1")
    @Max(value = 12, message = "Month must not exceed 12")
    private Integer originalMonth;

    private Integer originalYear;

    private Boolean isAnnualRecurring = true;

    @Min(value = 0, message = "Notify days before must be at least 0")
    @Max(value = 30, message = "Notify days before must not exceed 30")
    private Integer notifyDaysBefore = 0;

    private LocalTime notifyTime = LocalTime.of(9, 0);
}
