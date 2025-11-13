package com.meeting.microservices.TranscriptionDB;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "transcription")
public class Transcription {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_transcript")
    private Long id;

    @Column(name = "record_f_name")
    private String recordFileName;

    @Column(name = "id_fat")
    private Long idFat; // identifiant d’un worker/process éventuel

    @Column(name = "id_reunion", nullable = false)
    private Long idReunion; // FK vers meeting-service

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();

    @Column(name = "updated_at")
    private LocalDateTime updatedAt = LocalDateTime.now();

    @OneToMany(mappedBy = "transcription", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Segment> segments = new ArrayList<>();

    // -------------------- Getters & Setters --------------------

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getRecordFileName() {
        return recordFileName;
    }

    public void setRecordFileName(String recordFileName) {
        this.recordFileName = recordFileName;
    }

    public Long getIdFat() {
        return idFat;
    }

    public void setIdFat(Long idFat) {
        this.idFat = idFat;
    }

    public Long getIdReunion() {
        return idReunion;
    }

    public void setIdReunion(Long idReunion) {
        this.idReunion = idReunion;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public List<Segment> getSegments() {
        return segments;
    }

    public void setSegments(List<Segment> segments) {
        this.segments = segments;
    }

    // -------------------- Utilitaire --------------------
    public void addSegment(Segment s) {
        segments.add(s);
        s.setTranscription(this);
    }

    public void removeSegment(Segment s) {
        segments.remove(s);
        s.setTranscription(null);
    }
}
