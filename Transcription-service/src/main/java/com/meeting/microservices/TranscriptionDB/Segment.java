package com.meeting.microservices.TranscriptionDB;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "segment")
public class Segment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "start_time")
    private LocalDateTime startTime;

    @Column(name = "end_time")
    private LocalDateTime endTime;

    @Column(name = "text", columnDefinition = "TEXT")
    private String text;

    @Column(name = "confidence")
    private Double confidence;

    @ManyToOne
    @JoinColumn(name = "transcription_id")
    private Transcription transcription;

    @ManyToOne
    @JoinColumn(name = "locuteur_id")
    private Locuteur locuteur;

    // Getters / Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public LocalDateTime getStartTime() { return startTime; }
    public void setStartTime(LocalDateTime startTime) { this.startTime = startTime; }

    public LocalDateTime getEndTime() { return endTime; }
    public void setEndTime(LocalDateTime endTime) { this.endTime = endTime; }

    public String getText() { return text; }
    public void setText(String text) { this.text = text; }

    public Double getConfidence() { return confidence; }
    public void setConfidence(Double confidence) { this.confidence = confidence; }

    public Transcription getTranscription() { return transcription; }
    public void setTranscription(Transcription transcription) { this.transcription = transcription; }

    public Locuteur getLocuteur() { return locuteur; }
    public void setLocuteur(Locuteur locuteur) { this.locuteur = locuteur; }
}
