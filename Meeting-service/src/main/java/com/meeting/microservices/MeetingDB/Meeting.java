package com.meeting.microservices.MeetingDB;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;


@Entity 
@Table(name = "meeting")
public class Meeting {

    public Meeting(Long meetingid, String meetingParticipants, String meetingtitle, String meetingdescription, String meetingDate, String meetingPrevisualDuration, String meetingRealDuration, String meetingStatus) {
        setId(meetingid);
        setMeetingParticipants(meetingParticipants);
        setTitle(meetingtitle);
        setDescription(meetingdescription);
        setMeetingDate(meetingDate);
        setMeetingPrevisualDuration(meetingPrevisualDuration);
        setMeetingRealDuration(meetingRealDuration);
        setMeetingStatus(meetingStatus);
    }

    public Meeting() {
    }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long meetingid;

    @Column(name = "nb_participants")
    private String meetingParticipants;

    @Column(name = "title")
    private String meetingtitle;

    @Column(name = "description")
    private String meetingdescription;

    @Column(name = "date")
    private String meetingDate;

    @Column(name = "previsual_duration")
    private String meetingPrevisualDuration;

    @Column(name = "real_duration")
    private String meetingRealDuration;

    @Column(name = "status")
    private String meetingStatus;

    public Long getId() {
        return meetingid;
    }

    public void setId(Long id) {
        this.meetingid = id;
    }

    public String getMeetingParticipants() {
        return meetingParticipants;
    }

    public void setMeetingParticipants(String meetingParticipants) {
        this.meetingParticipants = meetingParticipants;
    }

    public String getTitle() {
        return meetingtitle;
    }

    public void setTitle(String title) {
        this.meetingtitle = title;
    }

    public String getDescription() {
        return meetingdescription;
    }

    public void setDescription(String description) {
        this.meetingdescription = description;
    }
    
    public String getMeetingDate() {
        return meetingDate;
    }

    public void setMeetingDate(String meetingDate) {
        this.meetingDate = meetingDate;
    }

    public String getMeetingPrevisualDuration() {
        return meetingPrevisualDuration;
    }

    public void setMeetingPrevisualDuration(String meetingPrevisualDuration) {
        this.meetingPrevisualDuration = meetingPrevisualDuration;
    }

    public String getMeetingRealDuration() {
        return meetingRealDuration;
    }

    public void setMeetingRealDuration(String meetingRealDuration) {
        this.meetingRealDuration = meetingRealDuration;
    }

    public String getMeetingStatus() {
        return meetingStatus;
    }

    public void setMeetingStatus(String meetingStatus) {
        this.meetingStatus = meetingStatus;
    }
}