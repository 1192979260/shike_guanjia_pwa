## ADDED Requirements

### Requirement: Service APIs match documented PRD operations
The system SHALL expose Flutter service interfaces for authentication, child profiles, training classes, lessons, attendance, cost statistics, and sync that cover the operations documented in `docs/api-design.md`.

#### Scenario: Provider calls a documented operation
- **WHEN** a Provider needs to perform a PRD-backed operation such as login, create child, create class, load lessons, check in, request leave, calculate monthly cost, or sync
- **THEN** the Provider SHALL be able to call a typed service method without directly accessing mock storage internals

#### Scenario: Service returns domain data
- **WHEN** a service operation succeeds
- **THEN** the service SHALL return the corresponding domain model, domain model list, primitive calculation result, or success result expected by its interface

### Requirement: Service operations validate required inputs
The system SHALL validate required fields and basic business constraints before mutating service state.

#### Scenario: Invalid child data is submitted
- **WHEN** child creation or update receives a blank name or invalid age
- **THEN** the service SHALL reject the operation and SHALL NOT create or update the child record

#### Scenario: Invalid class data is submitted
- **WHEN** class creation or update receives missing text fields, non-positive total hours, negative total fee, or an invalid schedule range
- **THEN** the service SHALL reject the operation and SHALL NOT create or update the class record

#### Scenario: Invalid auth data is submitted
- **WHEN** login receives an invalid phone number or a verification code that does not match the MVP six-digit rule
- **THEN** the auth service SHALL reject login and SHALL NOT create an authenticated session

### Requirement: Query operations support documented filters and ordering
The system SHALL implement documented query filters and stable ordering for children, classes, lessons, attendance records, leave records, and cost statistics.

#### Scenario: Children are queried by family
- **WHEN** children are loaded for a family
- **THEN** only children belonging to that family SHALL be returned in ascending creation order

#### Scenario: Classes are queried with filters
- **WHEN** classes are loaded with family, child, or status filters
- **THEN** only matching classes SHALL be returned in ascending start-time order

#### Scenario: Lessons are queried by class or date range
- **WHEN** lessons are loaded with class and date range filters
- **THEN** only matching lessons SHALL be returned in ascending scheduled-date order

### Requirement: Cross-entity operations preserve data invariants
The system SHALL keep related child, class, lesson, attendance, and cost data consistent after mutating operations.

#### Scenario: Child deletion cascades
- **WHEN** a child is deleted
- **THEN** all classes and lessons associated with that child SHALL also be deleted

#### Scenario: Class deletion cascades
- **WHEN** a class is deleted
- **THEN** all lessons and related attendance or leave records associated with that class SHALL also be deleted

#### Scenario: Class status changes
- **WHEN** a class is paused, resumed, or ended
- **THEN** the class status SHALL change to paused, active, or ended respectively and updated class data SHALL be returned

### Requirement: Service failures do not partially mutate state
The system SHALL avoid partial state changes when a service operation fails validation or references a missing entity.

#### Scenario: Missing class is checked in
- **WHEN** check-in references a lesson or class that does not exist
- **THEN** the service SHALL fail the operation and SHALL NOT create attendance records or decrement remaining hours

#### Scenario: Missing child is deleted
- **WHEN** deletion references a child that does not exist
- **THEN** the service SHALL return failure and SHALL NOT delete unrelated records

