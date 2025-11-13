package com.meeting.microservices.MeetingDB;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;

import java.util.HashSet;
import java.util.Set;


@Entity 
@Table(name = "meeting")
public class Meeting {

    @SuppressWarnings("java:S107")
    public Meeting(Long meetingid, String meetingParticipants, String meetingtitle, String meetingdescription, String meetingDate, String meetingPrevisualDuration, String meetingRealDuration, String meetingStatus, String meetingLanguage) {
        setId(meetingid);
        setMeetingParticipants(meetingParticipants);
        setTitle(meetingtitle);
        setDescription(meetingdescription);
        setMeetingDate(meetingDate);
        setMeetingPrevisualDuration(meetingPrevisualDuration);
        setMeetingRealDuration(meetingRealDuration);
        setMeetingStatus(meetingStatus);
        setMeetingLanguage(meetingLanguage);
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

    @Column(name = "language")
    private String meetingLanguage;

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(name = "meeting_participant",
        joinColumns = @JoinColumn(name = "meeting_id"),
        inverseJoinColumns = @JoinColumn(name = "participant_id"))
    private Set<Participant> participants = new HashSet<>();

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

    public String getMeetingLanguage() {
        return meetingLanguage;
    }

    public void setMeetingLanguage(String meetingLanguage) {
        this.meetingLanguage = meetingLanguage;
    }

    public Set<Participant> getParticipants() {
        return participants;
    }

    public void setParticipants(Set<Participant> participants) {
        this.participants = participants;
        updateParticipantCounter();
    }

    public void addParticipant(Participant participant) {
        participants.add(participant);
        updateParticipantCounter();
    }

    public void removeParticipant(Participant participant) {
        participants.remove(participant);
        updateParticipantCounter();
    }

    @PrePersist
    @PreUpdate
    private void updateParticipantCounter() {
        if (participants != null) {
            setMeetingParticipants(String.valueOf(participants.size()));
        }
    }
}