## ADDED Requirements

### Requirement: Create child profile
The system SHALL allow users to create child profiles with required information.

#### Scenario: Create child with valid data
- **WHEN** user enters child name and optional age/avatar
- **THEN** system creates child profile
- **AND** system generates default avatar if none provided
- **AND** system assigns unique child ID

#### Scenario: Create child without name
- **WHEN** user attempts to create child without name
- **THEN** system displays validation error
- **AND** system prevents profile creation

#### Scenario: First child creation flow
- **WHEN** new user creates first child profile
- **THEN** system prompts to create first training class
- **AND** system guides user through onboarding

### Requirement: Edit child profile
The system SHALL allow users to modify child profile information.

#### Scenario: Update child name
- **WHEN** user edits child name
- **THEN** system updates child profile
- **AND** changes reflect across all associated classes and lessons

#### Scenario: Update child age
- **WHEN** user edits child age
- **THEN** system updates child profile
- **AND** system validates age is positive integer

#### Scenario: Update child avatar
- **WHEN** user selects new avatar image
- **THEN** system updates child profile
- **AND** system displays new avatar in all views

### Requirement: Delete child profile
The system SHALL allow users to delete child profiles with cascade deletion of related data.

#### Scenario: Delete child with confirmation
- **WHEN** user confirms child deletion
- **THEN** system deletes child profile
- **AND** system cascades delete to all associated training classes
- **AND** system cascades delete to all associated lessons
- **AND** system cascades delete to all attendance records

#### Scenario: Prevent deletion without confirmation
- **WHEN** user taps delete button
- **THEN** system displays confirmation dialog
- **AND** system requires explicit confirmation

#### Scenario: Delete child with active classes warning
- **WHEN** user attempts to delete child with active training classes
- **THEN** system displays warning about data loss
- **AND** system requires explicit confirmation

### Requirement: List child profiles
The system SHALL display list of all child profiles for the family.

#### Scenario: Display children list
- **WHEN** user navigates to children management page
- **THEN** system displays all child profiles
- **AND** system shows name, age, and avatar for each child

#### Scenario: Empty children list
- **WHEN** family has no child profiles
- **THEN** system displays empty state
- **AND** system prompts to add first child

### Requirement: Child profile validation
The system SHALL validate child profile data before saving.

#### Scenario: Validate name length
- **WHEN** user enters name longer than 50 characters
- **THEN** system displays validation error
- **AND** system prevents saving

#### Scenario: Validate age range
- **WHEN** user enters age outside 0-18 range
- **THEN** system displays validation error
- **AND** system prevents saving

#### Scenario: Validate avatar format
- **WHEN** user uploads invalid image format
- **THEN** system displays format error
- **AND** system prevents saving
