package com.omnicalendar.repository;

import com.omnicalendar.model.Event;
import com.omnicalendar.model.enums.CalendarType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface EventRepository extends JpaRepository<Event, Long> {

    List<Event> findByUserId(Long userId);

    Optional<Event> findByIdAndUserId(Long id, Long userId);

    List<Event> findByUserIdAndCalendarType(Long userId, CalendarType calendarType);

    @Query("SELECT e FROM Event e WHERE e.user.id = :userId ORDER BY e.originalMonth, e.originalDay")
    List<Event> findByUserIdOrderByDate(@Param("userId") Long userId);

    @Query("SELECT e FROM Event e WHERE e.isAnnualRecurring = true")
    List<Event> findAllAnnualRecurringEvents();

    void deleteByIdAndUserId(Long id, Long userId);
}
