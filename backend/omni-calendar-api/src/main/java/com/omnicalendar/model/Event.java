package com.omnicalendar.model;

import com.omnicalendar.model.enums.CalendarType;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "events")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Event {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(name = "calendar_type", nullable = false)
    private CalendarType calendarType;

    @Column(name = "original_day", nullable = false)
    private Integer originalDay;

    @Column(name = "original_month", nullable = false)
    private Integer originalMonth;

    @Column(name = "original_year")
    private Integer originalYear;

    @Column(name = "is_annual_recurring")
    @Builder.Default
    private Boolean isAnnualRecurring = true;

    @Column(name = "notify_days_before")
    @Builder.Default
    private Integer notifyDaysBefore = 0;

    @Column(name = "notify_time")
    @Builder.Default
    private LocalTime notifyTime = LocalTime.of(9, 0);

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @OneToMany(mappedBy = "event", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<Notification> notifications = new ArrayList<>();
}
