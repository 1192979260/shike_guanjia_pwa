## ADDED Requirements

### Requirement: Check-in for attended lessons
The system SHALL allow users to mark lessons as attended.

#### Scenario: Check-in for scheduled lesson
- **WHEN** user taps check-in button for scheduled lesson
- **THEN** system marks lesson as attended
- **AND** system records check-in timestamp
- **AND** system decrements remaining session count
- **AND** system updates class progress

#### Scenario: Check-in with notes
- **WHEN** user adds notes during check-in
- **THEN** system saves marks lesson as attended
- **AND** system saves notes with attendance record
- **AND** system displays notes in lesson history

#### Scenario: Check-in for past lesson
- **WHEN** user checks in for missed lesson within 24 hours
- **THEN** system marks lesson as attended
- **AND** system marks attendance as backdated
- **AND** system sends backdated confirmation notification

#### Scenario: Prevent duplicate check-in
- **WHEN** user attempts to check-in for already attended lesson
- **THEN** system displays already attended message
- **AND** system prevents duplicate attendance record

### Requirement: Leave request management
The system SHALL allow users to request leave for upcoming lessons.

#### Scenario: Submit leave request
- **WHEN** user submits leave request for upcoming lesson
- **THEN** system marks lesson as on_leave
- **AND** system records leave timestamp
- **AND** system generates make-up lesson
- **AND** system does not decrement session count

#### Scenario: Leave request with reason
- **WHEN** user provides reason for leave request
- **THEN** system saves reason with leave record
- **AND** system displays reason in leave history

#### Scenario: Automatic make-up lesson generation
- **WHEN** leave request is approved
- **THEN** system generates make-up lesson
- **AND** system schedules make-up lesson in next available slot
- **AND** system marks make-up lesson as make_up

#### Scenario: Cancel leave request
- **WHEN** user cancels approved leave request
- **THEN** system removes leave status from lesson
- **AND** system deletes associated make-up lesson
- **AND** system restores original lesson status

### Requirement: Leave history tracking
The system SHALL maintain history of all leave requests.

#### Scenario: Display leave history
- **WHEN** user views leave history
- **THEN** system displays all leave requests
- **AND** system shows lesson details and dates
- **AND** system shows leave reasons and timestamps

#### Scenario: Filter leave history by child
- **WHEN** user filters leave history by child
- **THEN** system displays only leave requests for selected child

#### Scenario: Filter leave history by date range
- **WHEN** user filters leave history by date range
- **THEN** system displays leave requests within specified range

### Requirement: Make-up lesson management
The system SHALL manage make-up lessons generated from leave requests.

#### Scenario: Display make-up lesson indicator
- **WHEN** lesson is a make-up lesson
- **THEN** system displays visual indicator
- **AND** system shows original lesson reference

#### Scenario: Reschedule make-up lesson
- **WHEN** user reschedules make-up lesson
- **THEN** system updates make-up lesson date
- **AND** system preserves make-up status
- **AND** system checks for scheduling conflicts

#### Scenario: Cancel make-up lesson
- **WHEN** user cancels make-up lesson
- **THEN** system deletes make-up lesson
- **AND** system decrements session count
- **AND** system records cancellation reason

### Requirement: Attendance reminders
The system SHALL send reminders for upcoming lessons and pending attendance.

#### Scenario: Pre-lesson reminder
- **WHEN** lesson is scheduled for tomorrow
- **THEN** system sends reminder notification
- **AND** notification includes lesson details
- **AND** notification includes quick check-in action

#### Scenario: Post-lesson attendance reminder
- **WHEN** lesson was not checked in within 2 hours
- **THEN** system sends attendance reminder notification
- **AND** notification includes check-in prompt
- **AND** notification includes leave request option

#### Scenario: Backdated attendance reminder
- **WHEN** lesson was missed and not checked in within 24 hours
- **THEN** system sends backdated attendance reminder
- **AND** notification includes backdated check-in option
- **AND** notification includes leave request option

### Requirement: Attendance statistics
The system SHALL calculate and display attendance statistics.

#### Scenario: Calculate attendance rate
- **WHEN** user views attendance statistics
- **THEN** system calculates attendance rate as attended / total scheduled
- **AND** system excludes cancelled lessons from calculation

#### Scenario: Calculate leave rate
- **WHEN** user views attendance statistics
- **THEN** system calculates leave rate as on_leave / total scheduled
- **AND** system displays leave count and percentage

#### Scenario: Display monthly attendance summary
- **WHEN** user views monthly attendance report
- **THEN** system shows total lessons scheduled
- **AND** system shows lessons attended
- **AND** system shows lessons on leave
- **AND** system shows lessons missed

### Requirement: Attendance validation
The system SHALL validate attendance operations.

#### Scenario: Validate check-in timing
- **WHEN** user attempts to check-in for future lesson
- **THEN** system displays future lesson warning
- **AND** system prevents check-in unless explicitly confirmed

#### Scenario: Validate leave request timing
- **WHEN** user requests leave for past lesson
- **THEN** system displays past lesson warning
- **AND** system prevents leave request

#### Scenario: Validate make-up lesson availability
- **WHEN** system generates make-up lesson
- **THEN** system checks for available time slots
- **AND** system schedules make-up in next available slot
- **AND** system alerts user if no slots available within 30 days
