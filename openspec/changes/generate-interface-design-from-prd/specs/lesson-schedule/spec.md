## ADDED Requirements

### Requirement: Generate lessons from schedule rules
The system SHALL automatically generate lesson instances based on training class scheduling rules.

#### Scenario: Generate weekly schedule lessons
- **WHEN** class has weekly schedule rule (e.g., Mon, Wed, Fri)
- **THEN** system generates lessons for each scheduled day
- **AND** system respects start and end date boundaries
- **AND** system assigns sequential lesson numbers

#### Scenario: Generate monthly schedule lessons
- **WHEN** class has monthly schedule rule (e.g., first Saturday)
- **THEN** system generates lessons for each matching day
- **AND** system handles month boundaries correctly
- **AND** system assigns sequential lesson numbers

#### Scenario: Generate custom interval lessons
- **WHEN** class has custom interval rule (e.g., every 14 days)
- **THEN** system generates lessons at specified intervals
- **AND** system starts from initial class date
- **AND** system assigns sequential lesson numbers

#### Scenario: Handle end date boundary
- **WHEN** generated lesson date exceeds class end date
- **THEN** system stops lesson generation
- **AND** system does not create lessons beyond end date

### Requirement: Manual lesson adjustment
The system SHALL allow users to manually add, remove, or modify individual lessons.

#### Scenario: Add single lesson
- **WHEN** user manually adds a lesson for specific date
- **THEN** system creates lesson instance
- **AND** system marks lesson as manually added
- **AND** system assigns next available lesson number

#### Scenario: Remove single lesson
- **WHEN** user removes a specific lesson
- **THEN** system deletes lesson instance
- **AND** system marks lesson as manually removed
- **AND** system does not renumber subsequent lessons

#### Scenario: Modify lesson date
- **WHEN** user changes lesson date
- **THEN** system updates lesson date
- **AND** system checks for scheduling conflicts
- **AND** system displays warning if conflict detected

#### Scenario: Modify lesson time
- **WHEN** user changes lesson time
- **THEN** system updates lesson time
- **AND** system checks for scheduling conflicts
- **AND** system displays warning if conflict detected

### Requirement: Lesson conflict detection
The system SHALL detect and warn about scheduling conflicts between lessons.

#### Scenario: Detect time overlap for same child
- **WHEN** two lessons for same child overlap in time
- **THEN** system identifies conflict
- **AND** system displays conflict warning
- **AND** system highlights conflicting lessons in UI

#### Scenario: No conflict for different children
- **WHEN** lessons for different children overlap in time
- **THEN** system allows overlap
- **AND** system does not display warning

#### Scenario: Conflict on manual lesson creation
- **WHEN** user manually creates lesson with conflicting time
- **THEN** system detects conflict before creation
- **AND** system displays warning
- **AND** system allows creation with user confirmation

### Requirement: Temporary schedule suspension
The system SHALL support temporary suspension of lesson generation.

#### Scenario: Set suspension period
- **WHEN** user sets suspension start and end dates
- **THEN** system pauses lesson generation for specified period
- **AND** system excludes dates within suspension period
- **AND** system resumes generation after suspension end

#### Scenario: Override suspension for manual lesson
- **WHEN** user manually adds lesson during suspension period
- **THEN** system allows manual lesson creation
- **AND** system marks lesson as exception to suspension

### Requirement: Lesson status tracking
The system SHALL track lesson status through attendance lifecycle.

#### Scenario: Initial lesson status
- **WHEN** lesson is generated
- **THEN** system sets status to scheduled
- **AND** system displays lesson in upcoming schedule

#### Scenario: Lesson in progress
- **WHEN** current time matches lesson time
- **THEN** system sets status to in_progress
- **AND** system displays active reminder

#### Scenario: Lesson completed
- **WHEN** user marks lesson as attended
- **THEN** system sets status to completed
- **AND** system records attendance timestamp

#### Scenario: Lesson cancelled
- **WHEN** user cancels lesson
- **THEN** system sets status to cancelled
- **AND** system does not deduct from session count

### Requirement: Display lesson schedule
The system SHALL display lessons in calendar and list views.

#### Scenario: Display 3-week calendar view
- **WHEN** user views lesson schedule
- **THEN** system displays current week ±1 week
- **AND** system shows all lessons within date range
- **AND** system indicates lesson status with visual indicators

#### Scenario: Filter lessons by child
- **WHEN** user selects specific child filter
- **THEN** system displays only lessons for selected child
- **AND** system maintains 3-week view range

#### Scenario: Filter lessons by class
- **WHEN** user selects specific class filter
- **THEN** system displays only lessons for selected class
- **AND** system maintains 3-week view range

#### Scenario: Navigate between weeks
- **WHEN** user navigates to previous/next week
- **THEN** system updates displayed date range
- **AND** system loads lessons for new range
- **AND** system maintains filter selections

### Requirement: Lesson metadata
- **AND** system includes start and end time
- **AND** system includes location information
- **AND** system includes teacher information
- **AND** system includes attendance notes

#### Scenario: Update lesson metadata
- **WHEN** user edits lesson metadata
- **THEN** system updates lesson record
- **AND** system syncs changes to backend
