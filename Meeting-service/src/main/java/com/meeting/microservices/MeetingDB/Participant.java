package com.meeting.microservices.MeetingDB;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity 
@Table(name = "participant")
public class Participant {
	
    public Participant(){

    };

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long participantid;

    @Column(name = "lastname")
    private String participantlastname;

    @Column(name = "firstname")
    private String participantfirstname;

    public Long getId() {
        return participantid;
    }

    public void setId(Long id) {
        this.participantid = id;
    }

    public String getLastname() {
        return participantlastname;
    }

    public void setLastname(String lastname) {
        this.participantlastname = lastname;
    }

    public String getFirstname() {
        return participantfirstname;
    }

    public void setFirstname(String firstname) {
        this.participantfirstname = firstname;
    }
	
}