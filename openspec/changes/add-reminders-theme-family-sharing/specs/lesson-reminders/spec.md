## ADDED Requirements

### Requirement: Profile exposes lesson reminder settings
The system SHALL provide a lesson reminder entry from the profile area that opens a reminder settings screen.

#### Scenario: User opens reminder settings
- **WHEN** a logged-in user taps the lesson reminder entry in the profile area
- **THEN** the system SHALL navigate to a reminder settings screen showing the current reminder settings and notification permission state

#### Scenario: No lessons exist
- **WHEN** the user opens reminder settings while no lessons are available
- **THEN** the system SHALL still allow reminder settings to be viewed and saved

### Requirement: Reminder settings are modeled and persisted
The system SHALL model reminder settings with `enabled`, `advanceMinutes`, `includeTodayLessons`, `includeMakeupLessons`, and `updatedAt` fields using backend-compatible serialization.

#### Scenario: New user has default reminder settings
- **WHEN** no local or server reminder settings exist for the user
- **THEN** the system SHALL use enabled reminders, 60 advance minutes, today lesson reminders enabled, and makeup lesson reminders enabled

#### Scenario: Settings are saved locally
- **WHEN** reminder settings are loaded or updated successfully
- **THEN** the system SHALL store the latest settings locally for startup and offline use

#### Scenario: Settings are serialized for backend sync
- **WHEN** reminder settings are sent to or read from the backend
- **THEN** the system SHALL use `camelCase` fields and ISO-8601 date strings

### Requirement: Reminder settings sync with backend
The system SHALL read and update reminder settings through a typed reminder service backed by `GET /api/reminder-settings` and `PATCH /api/reminder-settings`.

#### Scenario: Provider initializes settings
- **WHEN** reminder state initializes
- **THEN** the system SHALL read cached settings first and then refresh from the backend when a logged-in session is available

#### Scenario: User updates reminder settings
- **WHEN** the user changes the reminder switch, advance time, today lesson option, or makeup lesson option
- **THEN** the system SHALL update local state, persist the latest settings, and send the updated settings to the backend

#### Scenario: Backend update fails
- **WHEN** the backend fails to save updated reminder settings
- **THEN** the system SHALL keep the user's current local settings and expose an error state that can be shown by the UI

### Requirement: Local notifications are scheduled for eligible lessons
The system SHALL schedule local notifications according to reminder settings and current lesson data.

#### Scenario: Enabled reminders schedule future lessons
- **WHEN** reminders are enabled and eligible scheduled lessons exist
- **THEN** the system SHALL schedule local notifications using each lesson time minus the selected advance minutes

#### Scenario: Disabled reminders cancel notifications
- **WHEN** reminders are disabled
- **THEN** the system SHALL cancel lesson reminder notifications

#### Scenario: Lesson state changes
- **WHEN** lesson data changes after create, edit, check-in, leave, cancellation, or class lifecycle mutation
- **THEN** the system SHALL reschedule lesson reminders using the latest lesson list and reminder settings

### Requirement: Ineligible lessons are not reminded
The system SHALL avoid scheduling reminders for lessons that should not notify the user.

#### Scenario: Completed lessons are skipped
- **WHEN** a lesson is already completed or checked in
- **THEN** the system SHALL NOT keep or create a reminder for that lesson

#### Scenario: Leave or cancelled lessons are skipped
- **WHEN** a lesson is marked as leave, cancelled, or otherwise inactive for attendance
- **THEN** the system SHALL NOT keep or create a reminder for that lesson

#### Scenario: Makeup reminders are excluded
- **WHEN** `includeMakeupLessons` is false and a lesson is a makeup lesson
- **THEN** the system SHALL NOT schedule a reminder for that lesson

### Requirement: Notification permission state is visible and non-blocking
The system SHALL show notification permission state on the reminder settings screen without blocking preference changes.

#### Scenario: Permission is granted
- **WHEN** notification permission is granted
- **THEN** the system SHALL show reminders as available and allow scheduling for eligible lessons

#### Scenario: Permission is denied
- **WHEN** notification permission is denied or unavailable
- **THEN** the system SHALL show a permission warning and a system-settings action while still allowing reminder settings to be saved

#### Scenario: Permission status changes
- **WHEN** the user returns from system notification settings
- **THEN** the system SHALL refresh and display the latest notification permission state
