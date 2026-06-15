## ADDED Requirements

### Requirement: User login with phone verification
The system SHALL authenticate users using phone number and SMS verification code.

#### Scenario: Successful login with valid code
- **WHEN** user enters valid phone number and verification code
- **THEN** system authenticates user and redirects to home page
- **AND** user session is established locally

#### Scenario: Login failure with invalid code
- **WHEN** user enters phone number with invalid verification code
- **THEN** system displays error message
- **AND** user remains on login page

#### Scenario: First-time user login
- **WHEN** new user logs in successfully
- **THEN** system creates new family account
- **AND** system redirects to onboarding flow (add first child)

### Requirement: Send verification code
The system SHALL send SMS verification code to user's phone number.

#### Scenario: Successful code sending
- **WHEN** user enters valid phone number and requests code
- **THEN** system sends SMS with 6-digit verification code
- **AND** code expires after 5 minutes

#### Scenario: Rate limiting on code requests
- **WHEN** user requests verification code more than 3 times in 1 minute
- **THEN** system blocks additional requests
- **AND** system displays rate limit message

### Requirement: Family member management
The system SHALL allow primary account holder to add family members with shared access.

#### Scenario: Add family member successfully
- **WHEN** primary user adds family member phone number
- **THEN** system sends invitation to family member
- **AND** family member gains full read/write access to family data

#### Scenario: Family member limit enforcement
- **WHEN** primary user attempts to add more than 1 family member
- **THEN** system displays limit message
- **AND** system prevents adding additional members

#### Scenario: Remove family member
- **WHEN** primary user removes family member
- **THEN** family member loses access to family data
- **AND** all their pending changes are discarded

### Requirement: Session persistence
The system SHALL maintain user session across app restarts.

#### Scenario: Session persists on app restart
- **WHEN** user closes and reopens app
- **THEN** user remains logged in
- **AND** user can access their data without re-authentication

#### Scenario: Session expires
- **WHEN** user session expires after 30 days of inactivity
- **THEN** system redirects to login page
- **AND** cached data remains accessible in offline mode

### Requirement: Logout
The system SHALL allow users to logout and clear local session data.

#### Scenario: Successful logout
- **WHEN** user taps logout button
- **THEN** system clears user session
- **AND** system redirects to login page
- **AND** local data remains for offline access
