package com.omnicalendar.controller;

import com.omnicalendar.dto.request.EventRequest;
import com.omnicalendar.dto.response.ApiResponse;
import com.omnicalendar.dto.response.EventResponse;
import com.omnicalendar.security.UserPrincipal;
import com.omnicalendar.service.EventService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/events")
@RequiredArgsConstructor
public class EventController {

    private final EventService eventService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<EventResponse>>> getAllEvents(
            @AuthenticationPrincipal UserPrincipal userPrincipal) {
        List<EventResponse> events = eventService.getUserEvents(userPrincipal.getId());
        return ResponseEntity.ok(ApiResponse.success(events));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<EventResponse>> getEvent(
            @PathVariable Long id,
            @AuthenticationPrincipal UserPrincipal userPrincipal) {
        EventResponse event = eventService.getEvent(id, userPrincipal.getId());
        return ResponseEntity.ok(ApiResponse.success(event));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<EventResponse>> createEvent(
            @Valid @RequestBody EventRequest request,
            @AuthenticationPrincipal UserPrincipal userPrincipal) {
        EventResponse event = eventService.createEvent(request, userPrincipal.getId());
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResponse.success("Event created successfully", event));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<EventResponse>> updateEvent(
            @PathVariable Long id,
            @Valid @RequestBody EventRequest request,
            @AuthenticationPrincipal UserPrincipal userPrincipal) {
        EventResponse event = eventService.updateEvent(id, request, userPrincipal.getId());
        return ResponseEntity.ok(ApiResponse.success("Event updated successfully", event));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteEvent(
            @PathVariable Long id,
            @AuthenticationPrincipal UserPrincipal userPrincipal) {
        eventService.deleteEvent(id, userPrincipal.getId());
        return ResponseEntity.ok(ApiResponse.success("Event deleted successfully", null));
    }

    @GetMapping("/upcoming")
    public ResponseEntity<ApiResponse<List<EventResponse>>> getUpcomingEvents(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @RequestParam(defaultValue = "30") int days) {
        List<EventResponse> events = eventService.getUpcomingEvents(userPrincipal.getId(), days);
        return ResponseEntity.ok(ApiResponse.success(events));
    }
}
