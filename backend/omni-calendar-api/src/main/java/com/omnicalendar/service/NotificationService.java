package com.omnicalendar.service;

import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import com.omnicalendar.model.Event;
import com.omnicalendar.model.User;
import com.omnicalendar.model.enums.NotificationStatus;
import com.omnicalendar.repository.NotificationRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
@Slf4j
public class NotificationService {

    private final NotificationRepository notificationRepository;

    @Transactional
    public void sendPushNotification(com.omnicalendar.model.Notification notification) {
        User user = notification.getUser();
        Event event = notification.getEvent();

        if (user.getFcmToken() == null || user.getFcmToken().isEmpty()) {
            log.warn("No FCM token for user: {}", user.getId());
            notification.setStatus(NotificationStatus.FAILED);
            notificationRepository.save(notification);
            return;
        }

        try {
            Message message = Message.builder()
                    .setToken(user.getFcmToken())
                    .setNotification(Notification.builder()
                            .setTitle("Upcoming Event: " + event.getTitle())
                            .setBody(buildNotificationBody(event, notification))
                            .build())
                    .putData("eventId", event.getId().toString())
                    .putData("calendarType", event.getCalendarType().name())
                    .build();

            String response = FirebaseMessaging.getInstance().send(message);
            log.info("Push notification sent: {}", response);

            notification.setStatus(NotificationStatus.SENT);
            notification.setSentAt(LocalDateTime.now());
        } catch (Exception e) {
            log.error("Failed to send push notification", e);
            notification.setStatus(NotificationStatus.FAILED);
        }

        notificationRepository.save(notification);
    }

    private String buildNotificationBody(Event event, com.omnicalendar.model.Notification notification) {
        StringBuilder body = new StringBuilder();

        if (notification.getScheduledDate().equals(
                java.time.LocalDate.now().plusDays(event.getNotifyDaysBefore()))) {
            if (event.getNotifyDaysBefore() == 0) {
                body.append("Today!");
            } else if (event.getNotifyDaysBefore() == 1) {
                body.append("Tomorrow!");
            } else {
                body.append("In ").append(event.getNotifyDaysBefore()).append(" days!");
            }
        }

        if (event.getDescription() != null && !event.getDescription().isEmpty()) {
            if (body.length() > 0) {
                body.append(" - ");
            }
            body.append(event.getDescription());
        }

        return body.toString();
    }
}
