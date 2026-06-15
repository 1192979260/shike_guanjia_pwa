## ADDED Requirements

### Requirement: Create training class
The system SHALL allow users to create training class profiles with scheduling rules.

#### Scenario: Create class with weekly schedule
- **WHEN** user enters class details and selects weekly schedule rule
- **THEN** system creates training class profile
- **AND** system generates lessons based on schedule rule
- **AND** system assigns unique class ID

#### Scenario: Create class with monthly schedule
- **WHEN** user enters class details and selects monthly schedule rule
- **THEN** system creates training class profile
- **AND** system generates lessons based on monthly pattern
- **AND** system assigns unique class ID

#### Scenario: Create class with custom interval
- **WHEN** user enters class details and custom interval days
- **THEN** system creates training class profile
- **AND** system generates lessons at specified intervals
- **AND** system assigns unique class ID

#### Scenario: Validate required fields
- **WHEN** user attempts to create class without required fields
- **THEN** system displays validation errors
- **AND** system prevents class creation

### Requirement: Edit training class
The system SHALL allow users to modify training class information.

#### Scenario: Update class basic information
- **WHEN** user edits class name, teacher info, or contact details
- **THEN** system updates class profile
- **AND** changes reflect across all views

#### Scenario: Update scheduling rules
- **WHEN** user modifies scheduling rules
- **THEN** system regenerates future lessons
- **AND** system preserves past lesson records
- **AND** system displays confirmation about lesson regeneration

#### Scenario: Update class costs
- **WHEN** user modifies total cost or total sessions
- **THEN** system updates class profile
- **AND** system recalculates per-session cost
- **AND** system updates cost statistics

### Requirement: Pause and resume class
The system SHALL allow users to temporarily pause and resume training classes.

#### Scenario: Pause active class
- **WHEN** user pauses an active training class
- **THEN** system sets class status to paused
- **AND** system stops generating new lessons
- **AND** existing lessons remain visible

#### Scenario: Resume paused class
- **WHEN** user resumes a paused training class
- **THEN** system sets class status to active
- **AND**** system resumes lesson generation
- **AND** system fills gap in lesson sequence

### Requirement: Class status management
The system SHALL manage training class lifecycle states.

#### Scenario: Auto-end class when sessions exhausted
- **WHEN** all class sessions are completed
- **THEN** system automatically sets class status to ended
- **AND** system archives class in completed classes list

#### Scenario: Manual class termination
- **WHEN** user manually ends a training class
- **THEN** system sets class status to ended
- **AND** system stops all future lesson generation
- **AND** system preserves historical data

#### Scenario: Renew ended class
- **WHEN** user renews an ended training class
- **THEN** system creates new class profile with same settings
- **AND** system prompts for new session package details
- **AND** original class remains in history

### Requirement: Delete training class
The system SHALL allow users to delete training classes with data cascade.

#### Scenario: Delete class with confirmation
- **WHEN** user confirms training class deletion
- **THEN** system deletes training class profile
- **AND** system cascades delete to all lessons
- **AND** system cascades delete to all attendance records
- **AND** system cascades delete to all cost records

#### Scenario: Prevent deletion without confirmation
- **WHEN** user taps delete button
- **THEN** system displays confirmation dialog
- **AND** system shows data loss warning

### Requirement: Class cost calculation
The system SHALL calculate per-session cost based on total cost and total sessions.

#### Scenario: Calculate per-session cost
- **WHEN** class is created with total cost and total sessions
- **THEN** system calculates per-session cost as total_cost / total_sessions
- **AND** system stores cost with 2 decimal precision

#### Scenario: Handle division edge cases
- **WHEN** total sessions is zero
- **THEN** system sets per-session cost to zero
- **AND** system displays validation error

### Requirement: Class conflict detection
The system SHALL detect scheduling conflicts between classes for the same child.

#### Scenario: Detect time overlap
- **WHEN** user creates class with schedule overlapping existing class
- **THEN** system detects conflict
- **AND** system displays warning about overlapping schedule
- **AND** system allows creation with user confirmation

#### Scenario: No conflict detection
- **WHEN** user creates class with no schedule conflicts
- **THEN** system creates class without warnings
- **AND** system generates lessons normally

### Requirement: List training classes
The system SHALL display training classes filtered by status and child.

#### Scenario: Display active classes
- **WHEN** user views active classes list
- **THEN** system shows all classes with active status
- **AND** system displays remaining sessions and next class time

#### Scenario: Display completed by child
- **WHEN** user filters classes by specific child
- **THEN** system shows only classes for selected child
- **AND** system groups by active and completed status

#### Scenario: Display empty class list
- **WHEN** family has no training classes
- **THEN** system displays empty state
- **AND** system prompts to add first class
