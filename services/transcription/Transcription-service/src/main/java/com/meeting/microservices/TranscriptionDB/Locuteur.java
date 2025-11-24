package com.meeting.microservices.TranscriptionDB;

import jakarta.persistence.*;
import java.util.List;

@Entity
@Table(name = "locuteur")
public class Locuteur {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "name")
    private String name;

    @Column(name = "participant_ref")
    private Long participantRef;

    @OneToMany(mappedBy = "locuteur", cascade = CascadeType.ALL)
    private List<Segment> segments;

    // Getters / Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public Long getParticipantRef() { return participantRef; }
    public void setParticipantRef(Long participantRef) { this.participantRef = participantRef; }

    public List<Segment> getSegments() { return segments; }
    public void setSegments(List<Segment> segments) { this.segments = segments; }
}
