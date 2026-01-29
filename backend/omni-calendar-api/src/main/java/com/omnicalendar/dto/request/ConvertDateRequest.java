package com.omnicalendar.dto.request;

import com.omnicalendar.model.enums.CalendarType;
import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ConvertDateRequest {

    @NotNull(message = "Day is required")
    @Min(value = 1, message = "Day must be at least 1")
    @Max(value = 31, message = "Day must not exceed 31")
    private Integer day;

    @NotNull(message = "Month is required")
    @Min(value = 1, message = "Month must be at least 1")
    @Max(value = 12, message = "Month must not exceed 12")
    private Integer month;

    private Integer year;

    @NotNull(message = "Calendar type is required")
    private CalendarType calendarType;

    @NotNull(message = "Target type is required")
    private CalendarType targetType;
}
