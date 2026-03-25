package com.omnicalendar.repository;

import com.omnicalendar.model.Notification;
import com.omnicalendar.model.enums.NotificationStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, Long> {

    List<Notification> findByUserId(Long userId);

    List<Notification> findByStatus(NotificationStatus status);

    @Query("SELECT n FROM Notification n WHERE n.status = :status " +
           "AND n.scheduledDate = :date AND n.scheduledTime <= :time")
    List<Notification> findPendingNotificationsToSend(
            @Param("status") NotificationStatus status,
            @Param("date") LocalDate date,
            @Param("time") LocalTime time);

    @Query("SELECT n FROM Notification n WHERE n.event.id = :eventId AND n.scheduledDate = :date")
    List<Notification> findByEventIdAndScheduledDate(
            @Param("eventId") Long eventId,
            @Param("date") LocalDate date);

    boolean existsByEventIdAndScheduledDate(Long eventId, LocalDate scheduledDate);
}
