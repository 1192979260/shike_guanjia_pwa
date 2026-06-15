## ADDED Requirements

### Requirement: Providers consume services instead of mock internals
Providers SHALL perform PRD-backed operations through service interfaces and SHALL NOT directly mutate shared mock storage.

#### Scenario: Provider loads data
- **WHEN** a Provider loads children, classes, lessons, attendance data, cost data, or sync state
- **THEN** it SHALL call the corresponding service method and publish the returned state to listeners

#### Scenario: Provider performs mutation
- **WHEN** a Provider creates, updates, deletes, checks in, requests leave, pauses, resumes, ends, or syncs
- **THEN** it SHALL call the corresponding service operation and update Provider state from service results

### Requirement: Providers refresh dependent state after cross-entity mutations
Providers SHALL refresh all affected state after service operations that mutate related entities.

#### Scenario: Child deletion affects classes and lessons
- **WHEN** a Provider deletes a child successfully
- **THEN** child state SHALL remove the child and related class and lesson state SHALL be refreshed before the UI is considered up to date

#### Scenario: Class mutation affects lessons and cost
- **WHEN** a Provider creates, deletes, pauses, resumes, ends, or renews a class successfully
- **THEN** class, lesson, and cost-related state SHALL be refreshed or invalidated consistently

#### Scenario: Attendance mutation affects class progress and statistics
- **WHEN** a Provider checks in a lesson or requests leave successfully
- **THEN** lesson, class progress, attendance history, and monthly statistics state SHALL reflect the service-side mutation

### Requirement: Providers expose loading and error states for API operations
Providers SHALL expose enough loading and error state for UI flows to handle service API failures.

#### Scenario: Service operation is in progress
- **WHEN** a Provider starts an asynchronous service operation
- **THEN** it SHALL expose a loading or busy state appropriate to that Provider until the operation completes

#### Scenario: Service operation fails
- **WHEN** a service operation returns failure or throws an unexpected error
- **THEN** the Provider SHALL expose an error state and SHALL NOT publish a successful local-only mutation

### Requirement: Provider API integration remains testable
Provider behavior SHALL be testable by injecting mock service implementations through the existing service locator or Provider construction path.

#### Scenario: Provider test injects services
- **WHEN** a test provides controlled mock service implementations
- **THEN** the Provider SHALL use those implementations without requiring Flutter UI rendering or LeanCloud network access

