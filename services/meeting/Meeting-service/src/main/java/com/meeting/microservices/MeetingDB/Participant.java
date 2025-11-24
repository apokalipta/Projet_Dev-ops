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
	
    public Participant() {
        // Required by JPA
    }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long participantid;

    @Column(name = "lastname")
    private String participantlastname;

    @Column(name = "firstname")
    private String participantfirstname;

    @Column(name = "email")
    private String participantemail;

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

    public String getEmail() {
        return participantemail;
    }

    public void setEmail(String email) {
        this.participantemail = email;
    }
	
}