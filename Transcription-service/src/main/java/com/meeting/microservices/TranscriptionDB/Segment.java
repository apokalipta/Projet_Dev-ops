package com.meeting.microservices.TranscriptionDB;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity 
@Table(name = "segment")
public class Segment {

    public Segment(){
        // Default constructor required by JPA
    }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long segmentId;
    
    

    
    
}