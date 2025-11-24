package com.meeting.microservices.TranscriptionDB;

public class SegmentDTO {
    private Long id;               // id du segment
    private Long transcriptionId;  // id de la transcription
    private Long locuteurId;       // id du locuteur
    private Double timeDepart;
    private Double timeEnd;
    private String texte;

    public SegmentDTO(Segment segment) {
        this.id = segment.getId();
        this.transcriptionId = segment.getTranscription() != null 
            ? segment.getTranscription().getId() : null;
        this.locuteurId = segment.getLocuteur() != null 
            ? segment.getLocuteur().getId() : null;
        this.timeDepart = segment.getTimeDepart();
        this.timeEnd = segment.getTimeEnd();
        this.texte = segment.getTexte();
    }

    
    public Long getId() { return id; }
    public Long getTranscriptionId() { return transcriptionId; }
    public Long getLocuteurId() { return locuteurId; }
    public Double getTimeDepart() { return timeDepart; }
    public Double getTimeEnd() { return timeEnd; }
    public String getTexte() { return texte; }
}