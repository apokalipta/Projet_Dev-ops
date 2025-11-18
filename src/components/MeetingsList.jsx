import React from 'react';
import { mockMeetings, formatMeetingForDisplay } from '../data/meetings';

const MeetingCard = ({ meeting }) => (
  <div style={{
    border: '1px solid #e0e0e0',
    borderRadius: '8px',
    padding: '16px',
    marginBottom: '16px',
    boxShadow: '0 2px 4px rgba(0,0,0,0.1)'
  }}>
    <h3 style={{ marginTop: 0 }}>{meeting.title}</h3>
    <p>{meeting.description}</p>
    <div style={{ margin: '12px 0' }}>
      <strong>Durée :</strong> {meeting.duration} minutes<br />
      <strong>Places disponibles :</strong> {meeting.participantSlots - meeting.participants.length} / {meeting.participantSlots}
    </div>
    
    {meeting.participants.length > 0 && (
      <div>
        <h4>Participants :</h4>
        <ul style={{ paddingLeft: '20px' }}>
          {meeting.participants.map((participant, index) => (
            <li key={index}>
              {participant.name} ({participant.email})
            </li>
          ))}
        </ul>
      </div>
    )}
  </div>
);

const MeetingsList = () => {
  const meetings = mockMeetings.map(formatMeetingForDisplay);

  return (
    <div style={{ maxWidth: '800px', margin: '0 auto', padding: '20px' }}>
      <h2>Liste des réunions</h2>
      {meetings.length > 0 ? (
        meetings.map((meeting) => (
          <MeetingCard key={meeting.id} meeting={meeting} />
        ))
      ) : (
        <p>Aucune réunion prévue pour le moment.</p>
      )}
    </div>
  );
};

export default MeetingsList;
