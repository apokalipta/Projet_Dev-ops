package com.meeting.microservices.TranscriptionDB;

import jakarta.persistence.*;

@Entity
@Table(name = "segment")
public class Segment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_segment")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_transcript", nullable = false)
    private Transcription transcription;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_locuteur", nullable = false)
    private Locuteur locuteur;

    @Column(name = "time_depart")
    private Double timeDepart;

    @Column(name = "duree")
    private Double duree;

    @Column(name = "texte", columnDefinition = "TEXT")
    private String texte;

    // -------------------- Getters & Setters --------------------

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Transcription getTranscription() {
        return transcription;
    }

    public void setTranscription(Transcription transcription) {
        this.transcription = transcription;
    }

    public Locuteur getLocuteur() {
        return locuteur;
    }

    public void setLocuteur(Locuteur locuteur) {
        this.locuteur = locuteur;
    }

    public Double getTimeDepart() {
        return timeDepart;
    }

    public void setTimeDepart(Double timeDepart) {
        this.timeDepart = timeDepart;
    }

    public Double getDuree() {
        return duree;
    }

    public void setDuree(Double duree) {
        this.duree = duree;
    }

    public String getTexte() {
        return texte;
    }

    public void setTexte(String texte) {
        this.texte = texte;
    }
}
