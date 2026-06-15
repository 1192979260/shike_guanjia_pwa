## ADDED Requirements

### Requirement: Calculate per-session cost
The system SHALL calculate cost per session based on total class cost and total sessions.

#### Scenario: Calculate standard per-session cost
- **WHEN** class has total cost and total sessions
- **THEN** system calculates per_session_cost = total_cost / total_sessions
- **AND** system stores result with 2 decimal precision

#### Scenario: Handle zero total sessions
- **WHEN** class has zero total sessions
- **THEN** system sets per_session_cost to 0
- **AND** system displays validation error

#### Scenario: Handle zero total cost
- **WHEN** class has zero total cost
- **THEN** system sets per_session_cost to 0
- **AND** system allows free class creation

### Requirement: Calculate monthly cost
The system SHALL calculate total monthly cost across all classes.

#### Scenario: Calculate monthly attended cost
- **WHEN** user views monthly cost report
- **THEN** system sums cost for all attended lessons in month
- **AND** system uses per_session_cost for each class
- **AND** system displays total monthly spending

#### Scenario: Calculate monthly cost by child
- **WHEN** user filters monthly cost by child
- **THEN** system sums cost only for selected child's classes
- **AND** system displays child-specific monthly spending

#### Scenario: Calculate monthly cost by class
- **WHEN** user views class detail monthly cost
- **THEN** system calculates attended lessons × per_session_cost
- **AND** system displays class monthly spending

### Requirement: Calculate remaining cost value
The system SHALL calculate remaining monetary value based on unused sessions.

#### Scenario: Calculate remaining class cost
- **WHEN** user views class details
- **THEN** system calculates remaining_cost = remaining_sessions × per_session_cost
- **AND** system displays remaining value

#### Scenario: Calculate total remaining value
- **WHEN** user views dashboard
- **THEN** system sums remaining cost across all active classes
- **AND** system displays total remaining value

#### Scenario: Handle completed class
- **WHEN** class has no remaining sessions
- **THEN** system sets remaining cost to 0
- **AND** system displays class as completed

### Requirement: Generate monthly cost report
The system SHALL generate detailed monthly cost reports.

#### Scenario: Generate monthly summary
- **WHEN** user requests monthly report
- **THEN** system generates report with total attended sessions
- **AND** system includes total leave sessions
- **AND** system includes total monthly cost
- **AND** system includes cost breakdown by class

#### Scenario: Generate cost breakdown by class
- **WHEN** user views monthly report
- **THEN** system shows cost per class
- **AND** system shows session count per class
- **AND** system shows cost percentage per class

#### Scenario: Generate cost trend
- **WHEN** user views 6-month cost history
- **THEN** system displays monthly cost trend
- **AND** system shows month-over-month comparison
- **AND** system highlights peak spending months

### Requirement: Cost aggregation across family
The system SHALL aggregate costs across all family members' classes.

#### Scenario: Calculate family total cost
- **WHEN** user views family dashboard
- **THEN** system sums costs across all children's classes
- **AND** system displays total family spending

#### Scenario: Compare spending by child
- **WHEN** user views cost comparison
- **THEN** system shows cost per child
- **AND** system calculates percentage of total per child
- **AND** system displays spending comparison chart

### Requirement: Cost data export
The system SHALL allow users to export cost data in various formats.

#### Scenario: Export cost data as CSV
- **WHEN** user exports cost data
- **THEN** system generates CSV file with cost records
- **AND** file includes date, class, child, session count, cost
- **AND** system initiates file download

#### Scenario: Export monthly report as PDF
- **WHEN** user exports monthly report
- **THEN** system generates PDF with cost summary
- **AND** PDF includes tables and charts
- **AND** system initiates file download

#### Scenario: Export custom date range
- **WHEN** user specifies custom date range for export
- **THEN** system filters cost data by date range
- **AND** system exports only data within range

### Requirement: Cost statistics caching
The system SHALL cache calculated cost statistics for performance.

#### Scenario: Cache monthly cost calculation
- **WHEN** user views monthly cost report
- **THEN** system calculates and caches result
- **AND** subsequent views use cached data
- **AND** cache invalidates on attendance changes

#### Scenario: Invalidate cache on data change
- **WHEN** user marks lesson as attended
- **THEN** system invalidates cost cache
- **AND** system recalculates on next request

### Requirement: Cost validation
The system SHALL validate cost data integrity.

#### Scenario: Validate cost calculation consistency
- **WHEN** system calculates costs
- **THEN** system verifies total_cost = sum of all session costs
- **AND** system alerts on calculation discrepancies

#### Scenario: Validate cost data types
- **WHEN** system processes cost data
- **THEN** system ensures all cost values are numeric
- **AND** system handles null or undefined values gracefully
