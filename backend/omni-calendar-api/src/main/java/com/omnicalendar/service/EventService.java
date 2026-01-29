package com.omnicalendar.service;

import com.omnicalendar.dto.request.EventRequest;
import com.omnicalendar.dto.response.EventResponse;
import com.omnicalendar.exception.ResourceNotFoundException;
import com.omnicalendar.model.Event;
import com.omnicalendar.model.User;
import com.omnicalendar.repository.EventRepository;
import com.omnicalendar.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class EventService {

    private final EventRepository eventRepository;
    private final UserRepository userRepository;
    private final CalendarConversionService calendarService;

    public List<EventResponse> getUserEvents(Long userId) {
        return eventRepository.findByUserIdOrderByDate(userId).stream()
                .map(this::toEventResponse)
                .collect(Collectors.toList());
    }

    public EventResponse getEvent(Long eventId, Long userId) {
        Event event = eventRepository.findByIdAndUserId(eventId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("Event", "id", eventId));
        return toEventResponse(event);
    }

    @Transactional
    public EventResponse createEvent(EventRequest request, Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", userId));

        Event event = Event.builder()
                .user(user)
                .title(request.getTitle())
                .description(request.getDescription())
                .calendarType(request.getCalendarType())
                .originalDay(request.getOriginalDay())
                .originalMonth(request.getOriginalMonth())
                .originalYear(request.getOriginalYear())
                .isAnnualRecurring(request.getIsAnnualRecurring())
                .notifyDaysBefore(request.getNotifyDaysBefore())
                .notifyTime(request.getNotifyTime())
                .build();

        event = eventRepository.save(event);
        log.info("Event created: {} for user: {}", event.getTitle(), user.getEmail());

        return toEventResponse(event);
    }

    @Transactional
    public EventResponse updateEvent(Long eventId, EventRequest request, Long userId) {
        Event event = eventRepository.findByIdAndUserId(eventId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("Event", "id", eventId));

        event.setTitle(request.getTitle());
        event.setDescription(request.getDescription());
        event.setCalendarType(request.getCalendarType());
        event.setOriginalDay(request.getOriginalDay());
        event.setOriginalMonth(request.getOriginalMonth());
        event.setOriginalYear(request.getOriginalYear());
        event.setIsAnnualRecurring(request.getIsAnnualRecurring());
        event.setNotifyDaysBefore(request.getNotifyDaysBefore());
        event.setNotifyTime(request.getNotifyTime());

        event = eventRepository.save(event);
        log.info("Event updated: {}", event.getId());

        return toEventResponse(event);
    }

    @Transactional
    public void deleteEvent(Long eventId, Long userId) {
        Event event = eventRepository.findByIdAndUserId(eventId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("Event", "id", eventId));

        eventRepository.delete(event);
        log.info("Event deleted: {}", eventId);
    }

    public List<EventResponse> getUpcomingEvents(Long userId, int daysAhead) {
        List<Event> events = eventRepository.findByUserId(userId);
        LocalDate today = LocalDate.now();
        LocalDate endDate = today.plusDays(daysAhead);

        return events.stream()
                .map(event -> {
                    EventResponse response = toEventResponse(event);
                    return response;
                })
                .filter(response -> {
                    LocalDate nextDate = response.getNextGregorianDate();
                    return nextDate != null &&
                           !nextDate.isBefore(today) &&
                           !nextDate.isAfter(endDate);
                })
                .sorted((e1, e2) -> e1.getNextGregorianDate().compareTo(e2.getNextGregorianDate()))
                .collect(Collectors.toList());
    }

    private EventResponse toEventResponse(Event event) {
        LocalDate nextGregorianDate = calculateNextGregorianDate(event);

        return EventResponse.builder()
                .id(event.getId())
                .title(event.getTitle())
                .description(event.getDescription())
                .calendarType(event.getCalendarType())
                .originalDay(event.getOriginalDay())
                .originalMonth(event.getOriginalMonth())
                .originalYear(event.getOriginalYear())
                .isAnnualRecurring(event.getIsAnnualRecurring())
                .notifyDaysBefore(event.getNotifyDaysBefore())
                .notifyTime(event.getNotifyTime())
                .nextGregorianDate(nextGregorianDate)
                .createdAt(event.getCreatedAt())
                .updatedAt(event.getUpdatedAt())
                .build();
    }

    private LocalDate calculateNextGregorianDate(Event event) {
        try {
            if (event.getIsAnnualRecurring()) {
                LocalDate dateThisYear = calendarService.getGregorianDateForCurrentYear(
                        event.getOriginalDay(),
                        event.getOriginalMonth(),
                        event.getCalendarType()
                );

                if (dateThisYear.isBefore(LocalDate.now())) {
                    int nextYear = calendarService.getCurrentYearInCalendar(event.getCalendarType()) + 1;
                    return calendarService.convertToGregorian(
                            event.getOriginalDay(),
                            event.getOriginalMonth(),
                            nextYear,
                            event.getCalendarType()
                    );
                }
                return dateThisYear;
            } else if (event.getOriginalYear() != null) {
                return calendarService.convertToGregorian(
                        event.getOriginalDay(),
                        event.getOriginalMonth(),
                        event.getOriginalYear(),
                        event.getCalendarType()
                );
            }
        } catch (Exception e) {
            log.error("Error calculating Gregorian date for event: {}", event.getId(), e);
        }
        return null;
    }
}
