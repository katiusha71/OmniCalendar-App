package com.omnicalendar.dto.response;

import com.omnicalendar.model.enums.CalendarType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ConvertedDateResponse {

    private CalendarType sourceCalendar;
    private CalendarType targetCalendar;
    private DateInfo sourceDate;
    private DateInfo targetDate;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class DateInfo {
        private Integer day;
        private Integer month;
        private Integer year;
        private String monthName;
        private String dayOfWeek;
        private String formatted;
    }
}
