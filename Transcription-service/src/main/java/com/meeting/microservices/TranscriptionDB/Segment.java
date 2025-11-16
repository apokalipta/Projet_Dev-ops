package com.meeting.microservices.TranscriptionDB;

import jakarta.persistence.*;

@Entity
@Table(name = "segment")
public class Segment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_segment")
    private Long id;

//A CONFIRMER stocké en tant qu'ID de la transcription au lieu de l'objet entier
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_transcript", nullable = false)
    //private Long id_transcript;
    private Transcription transcription;

    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_locuteur", nullable = false)
    //private Long id_locuteur;
    private Locuteur locuteur;

    @Column(name = "time_depart")
    private Double timeDepart;

    @Column(name = "time_end")
    private Double timeEnd;

    @Column(name = "texte", columnDefinition = "TEXT")
    private String texte;

    // -------------------- Getters & Setters --------------------

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    //public Transcription getTranscription() {
    public Transcription getTranscription() {
        return transcription;
        //return id_transcript;
    }

    public void setTranscription(Transcription transcription) {
        this.transcription = transcription;
    }
    
    public Locuteur getLocuteur() {
        return locuteur;
        //return id_locuteur;
    }

    public void setLocuteur(Locuteur locuteur) {
       this.locuteur = locuteur;
    }
    /*public void setId_locuteur(Long id_locuteur) {
        this.id_locuteur = id_locuteur;    
    }*/

    public Double getTimeDepart() {
        return timeDepart;
    }

    public void setTimeDepart(Double timeDepart) {
        this.timeDepart = timeDepart;
    }

    public Double getTimeEnd() {
        return timeEnd;
    }

    public void setTimeEnd(Double timeEnd) {
        this.timeEnd = timeEnd;
    }

    public String getTexte() {
        return texte;
    }

    public void setTexte(String texte) {
        this.texte = texte;
    }
}
