import express from 'express'
import cors from 'cors'
import helmet from 'helmet'
import morgan from 'morgan'
import { v4 as uuid } from 'uuid'

const app = express()
const port = process.env.PORT || 5000

// In-memory datastore (à remplacer par une base de données réelle)
const meetings = new Map()

// Middlewares globaux
app.use(helmet())
app.use(cors({ origin: '*', methods: ['GET', 'POST', 'PUT', 'DELETE'] }))
app.use(express.json({ limit: '1mb' }))
app.use(morgan('dev'))

/**
 * Helpers
 */
const isIsoDate = (value) => {
  if (typeof value !== 'string') return false
  const date = new Date(value)
  return !Number.isNaN(date.getTime())
}

const buildMeetingResponse = (meeting) => ({
  id: meeting.id,
  title: meeting.title,
  description: meeting.description,
  scheduledAt: meeting.scheduledAt,
  durationMinutes: meeting.durationMinutes,
  status: meeting.status,
  participants: meeting.participants,
  participantSlots: meeting.participantSlots,
  metadata: meeting.metadata,
  createdAt: meeting.createdAt,
  updatedAt: meeting.updatedAt
})

/**
 * @route POST /api/meeting
 * @description Crée une nouvelle réunion (voir endpoint.md)
 */
app.post('/api/meeting', (req, res) => {
  const {
    name,
    title, // accepte aussi title pour compatibilité API future
    description = '',
    date,
    scheduledAt,
    duration,
    durationMinutes,
    participants,
    participantSlots,
    selectedMicrophone,
    autoStart = false,
    sendReminders = false,
    metadata = {}
  } = req.body || {}

  const meetingTitle = title ?? name
  const meetingDate = scheduledAt ?? date
  const durationValue = Number(durationMinutes ?? duration)
  const slotsValue = Number(participantSlots ?? participants)

  const errors = {}

  if (!meetingTitle || typeof meetingTitle !== 'string' || meetingTitle.trim().length < 3) {
    errors.title = 'Le titre (name) est requis et doit contenir au moins 3 caractères.'
  }

  if (!meetingDate || !isIsoDate(meetingDate)) {
    errors.date = 'La date (scheduledAt) doit être un ISO-8601 valide.'
  }

  if (!Number.isFinite(durationValue) || durationValue <= 0) {
    errors.duration = 'La durée (durationMinutes) doit être un nombre positif.'
  }

  if (!Number.isFinite(slotsValue) || slotsValue <= 0) {
    errors.participants = 'Le nombre de participants doit être un nombre positif.'
  }

  if (Object.keys(errors).length > 0) {
    return res.status(400).json({
      success: false,
      message: 'Données de réunion invalides',
      errors
    })
  }

  const now = new Date().toISOString()
  const meetingId = uuid()

  const meeting = {
    id: meetingId,
    title: meetingTitle.trim(),
    description: description?.trim?.() ?? '',
    scheduledAt: new Date(meetingDate).toISOString(),
    durationMinutes: Math.round(durationValue),
    participantSlots: Math.round(slotsValue),
    status: 'scheduled',
    participants: [],
    metadata: {
      selectedMicrophone: selectedMicrophone ?? null,
      autoStart: Boolean(autoStart),
      sendReminders: Boolean(sendReminders),
      ...metadata
    },
    createdAt: now,
    updatedAt: now
  }

  meetings.set(meetingId, meeting)

  return res.status(201).json({
    success: true,
    message: 'Réunion créée avec succès',
    data: buildMeetingResponse(meeting)
  })
})

// Santé du service
app.get('/health', (_req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() })
})

app.listen(port, () => {
  console.log(`✅ API Transcript IA démarrée sur http://localhost:${port}`)
})


