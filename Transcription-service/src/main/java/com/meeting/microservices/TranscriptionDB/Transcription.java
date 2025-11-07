package com.meeting.microservices.TranscriptionDB;

import jakarta.persistence.*;
import java.util.List;

@Entity
@Table(name = "transcription")
public class Transcription {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "meeting_id")
    private Long meetingId;

    @Column(name = "status")
    private String status;

    @Column(name = "confidence_avg")
    private Double confidenceAvg;

    @OneToMany(mappedBy = "transcription", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Segment> segments;

    // Getters / Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getMeetingId() { return meetingId; }
    public void setMeetingId(Long meetingId) { this.meetingId = meetingId; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Double getConfidenceAvg() { return confidenceAvg; }
    public void setConfidenceAvg(Double confidenceAvg) { this.confidenceAvg = confidenceAvg; }

    public List<Segment> getSegments() { return segments; }
    public void setSegments(List<Segment> segments) { this.segments = segments; }
}
