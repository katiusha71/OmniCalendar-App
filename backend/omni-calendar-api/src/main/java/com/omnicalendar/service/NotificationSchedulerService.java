package com.omnicalendar.service;

import com.omnicalendar.model.Event;
import com.omnicalendar.model.Notification;
import com.omnicalendar.model.enums.NotificationStatus;
import com.omnicalendar.repository.EventRepository;
import com.omnicalendar.repository.NotificationRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class NotificationSchedulerService {

    private final EventRepository eventRepository;
    private final NotificationRepository notificationRepository;
    private final CalendarConversionService calendarService;
    private final NotificationService notificationService;

    @Scheduled(cron = "0 0 0 * * *")
    @Transactional
    public void scheduleNotificationsForYear() {
        log.info("Running daily notification scheduler...");

        List<Event> recurringEvents = eventRepository.findAllAnnualRecurringEvents();

        for (Event event : recurringEvents) {
            try {
                scheduleNotificationForEvent(event);
            } catch (Exception e) {
                log.error("Error scheduling notification for event: {}", event.getId(), e);
            }
        }

        log.info("Scheduled notifications for {} events", recurringEvents.size());
    }

    private void scheduleNotificationForEvent(Event event) {
        LocalDate eventDate = calendarService.getGregorianDateForCurrentYear(
                event.getOriginalDay(),
                event.getOriginalMonth(),
                event.getCalendarType()
        );

        LocalDate notificationDate = eventDate.minusDays(event.getNotifyDaysBefore());

        if (notificationDate.isBefore(LocalDate.now())) {
            return;
        }

        if (notificationRepository.existsByEventIdAndScheduledDate(event.getId(), notificationDate)) {
            return;
        }

        Notification notification = Notification.builder()
                .event(event)
                .user(event.getUser())
                .scheduledDate(notificationDate)
                .scheduledTime(event.getNotifyTime())
                .status(NotificationStatus.PENDING)
                .build();

        notificationRepository.save(notification);
        log.debug("Scheduled notification for event {} on {}", event.getId(), notificationDate);
    }

    @Scheduled(fixedRate = 60000)
    @Transactional
    public void processPendingNotifications() {
        LocalDate today = LocalDate.now();
        LocalTime now = LocalTime.now();

        List<Notification> pendingNotifications = notificationRepository
                .findPendingNotificationsToSend(NotificationStatus.PENDING, today, now);

        for (Notification notification : pendingNotifications) {
            try {
                notificationService.sendPushNotification(notification);
            } catch (Exception e) {
                log.error("Error processing notification: {}", notification.getId(), e);
            }
        }

        if (!pendingNotifications.isEmpty()) {
            log.info("Processed {} pending notifications", pendingNotifications.size());
        }
    }
}
