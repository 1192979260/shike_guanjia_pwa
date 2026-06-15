## ADDED Requirements

### Requirement: Mock services provide complete MVP behavior
The system SHALL provide mock implementations for every service API needed by the MVP so the app can run without LeanCloud.

#### Scenario: App starts in mock mode
- **WHEN** the service locator initializes MVP services
- **THEN** auth, child, class, lesson, attendance, cost, and sync service dependencies SHALL resolve to usable mock implementations

#### Scenario: Mock service stores created entities
- **WHEN** a mock create operation succeeds
- **THEN** the created entity SHALL be available to subsequent read, update, delete, and filtered query operations in the same app session

### Requirement: Mock authentication simulates phone verification and family setup
The mock auth service SHALL simulate SMS login and establish a user/family session for MVP use.

#### Scenario: Verification code is sent
- **WHEN** a valid mainland China phone number requests a verification code
- **THEN** the mock auth service SHALL report success without contacting a real SMS provider

#### Scenario: First login creates family context
- **WHEN** a valid phone and six-digit code are used for first login
- **THEN** the mock auth service SHALL create or return a user, create or return a family, add the primary family member, and mark the session as logged in

#### Scenario: Logout clears session
- **WHEN** logout is called
- **THEN** the mock auth service SHALL clear the current user session while preserving mock domain data unless explicitly reset by test setup

### Requirement: Mock class operations generate and maintain related lessons
The mock class service SHALL coordinate with lesson storage for class lifecycle operations.

#### Scenario: Class is created with a recurring rule
- **WHEN** a valid class is created
- **THEN** the mock implementation SHALL store the class and generate scheduled lessons according to the class recurring rule and date bounds

#### Scenario: Class is paused
- **WHEN** an active class is paused
- **THEN** future scheduling for that class SHALL be treated as paused and the class SHALL no longer appear in active class queries

#### Scenario: Class is ended
- **WHEN** a class is ended
- **THEN** the class SHALL be marked ended and SHALL appear in completed class queries

### Requirement: Mock lesson and attendance operations apply side effects
The mock lesson and attendance services SHALL update all affected domain entities for check-in and leave flows.

#### Scenario: Lesson is checked in
- **WHEN** an eligible scheduled lesson is checked in
- **THEN** the lesson SHALL be marked completed, check-in metadata SHALL be recorded, attendance SHALL be stored, and the class remaining hours SHALL decrement exactly once

#### Scenario: Lesson is checked in twice
- **WHEN** a completed lesson is checked in again
- **THEN** the service SHALL NOT decrement remaining hours a second time

#### Scenario: Leave is requested
- **WHEN** leave is requested for an eligible lesson
- **THEN** the lesson SHALL be marked leave, a leave record SHALL be stored, and no class hours SHALL be deducted

### Requirement: Mock cost service calculates from actual domain state
The mock cost service SHALL calculate cost statistics from current class and completed lesson data rather than fixed placeholder values.

#### Scenario: Monthly cost is calculated
- **WHEN** monthly cost is requested for a family, month, and optional child or class filter
- **THEN** the result SHALL equal completed lesson count multiplied by each class per-session cost

#### Scenario: Remaining value is calculated
- **WHEN** remaining value is requested
- **THEN** the result SHALL equal the sum of each active class remaining hours multiplied by its per-session cost

### Requirement: Mock sync reports deterministic MVP status
The mock sync service SHALL simulate offline-first sync status without requiring network access.

#### Scenario: Sync succeeds while online
- **WHEN** mock sync runs while online
- **THEN** it SHALL mark pending operations as synced, update the last sync status, and return a successful sync result

#### Scenario: Sync is attempted while offline
- **WHEN** mock sync runs while offline
- **THEN** it SHALL retain pending operations and return a failed or pending sync result that Providers can display

