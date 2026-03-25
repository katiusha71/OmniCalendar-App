package com.omnicalendar.dto.request;

import com.omnicalendar.model.enums.CalendarType;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class RegisterRequest {

    @NotBlank(message = "Email is required")
    @Email(message = "Invalid email format")
    private String email;

    @NotBlank(message = "Password is required")
    @Size(min = 8, message = "Password must be at least 8 characters")
    private String password;

    @Size(max = 100, message = "Full name must not exceed 100 characters")
    private String fullName;

    private CalendarType preferredCalendar = CalendarType.GREGORIAN;

    private String timezone = "UTC";
}
