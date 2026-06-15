## ADDED Requirements

### Requirement: Profile exposes family sharing
The system SHALL provide a family sharing entry from the profile area that opens a family sharing screen.

#### Scenario: User opens family sharing
- **WHEN** a logged-in user taps the family sharing entry in the profile area
- **THEN** the system SHALL navigate to a family sharing screen showing current family information and member state

#### Scenario: Family data is loading
- **WHEN** family information or members are being loaded
- **THEN** the system SHALL show a loading state instead of stale mutation results

### Requirement: Family sharing page displays family and members
The system SHALL display the current family name, current family members, each member relation, and the MVP member limit.

#### Scenario: Family has members
- **WHEN** family data loads successfully
- **THEN** the system SHALL show the family name and all current members with relation labels such as mother or father

#### Scenario: Family is at member limit
- **WHEN** the current family already has two members
- **THEN** the system SHALL hide or disable member addition and show that the current family supports at most two members

#### Scenario: Family data is unavailable
- **WHEN** the backend returns no current family for the logged-in user
- **THEN** the system SHALL show an actionable empty or error state instead of crashing

### Requirement: Family provider manages family mutations
The system SHALL route family loading, member addition, and member removal through provider-managed state rather than screen-local HTTP calls.

#### Scenario: Family screen initializes
- **WHEN** the family sharing screen is opened
- **THEN** the system SHALL load the current family and family members through the family state layer

#### Scenario: Member mutation starts
- **WHEN** the user adds or removes a family member
- **THEN** the system SHALL expose loading state for that mutation and prevent duplicate submission until it completes

### Requirement: User can add a family member
The system SHALL allow adding a family member by phone number and relation when the family has not reached the MVP member limit.

#### Scenario: Member is added successfully
- **WHEN** the user submits a valid phone number and relation and the backend accepts it
- **THEN** the system SHALL refresh the family member list and show the new member

#### Scenario: Phone number is invalid
- **WHEN** the user submits an invalid phone number
- **THEN** the system SHALL show a field-level or form-level validation message and SHALL NOT submit the add request

#### Scenario: Family is already full
- **WHEN** the user attempts to add a member after the family reaches two members
- **THEN** the system SHALL prevent the operation or show the `FAMILY_MEMBER_LIMIT_REACHED` message

### Requirement: User can remove a family member
The system SHALL require confirmation before removing a family member and SHALL refresh member state after successful removal.

#### Scenario: User confirms removal
- **WHEN** the user confirms removal of a family member and the backend accepts it
- **THEN** the system SHALL refresh the family member list and remove that member from the visible list

#### Scenario: User cancels removal
- **WHEN** the user dismisses the removal confirmation
- **THEN** the system SHALL NOT call the remove member service

#### Scenario: Last member cannot be removed
- **WHEN** the backend rejects removal with `CANNOT_REMOVE_LAST_MEMBER`
- **THEN** the system SHALL show that at least one family member must remain

### Requirement: Family errors use directed user messages
The system SHALL map known backend family error codes to user-understandable messages.

#### Scenario: Member limit error
- **WHEN** the backend returns `FAMILY_MEMBER_LIMIT_REACHED`
- **THEN** the system SHALL show that the current family supports at most two members

#### Scenario: Duplicate member error
- **WHEN** the backend returns `USER_ALREADY_IN_FAMILY`
- **THEN** the system SHALL show that the phone number already belongs to the current family

#### Scenario: Invite expired error
- **WHEN** the backend returns `FAMILY_INVITE_EXPIRED`
- **THEN** the system SHALL show that the invite expired and the user should resend it

#### Scenario: Invite not found error
- **WHEN** the backend returns `FAMILY_INVITE_NOT_FOUND`
- **THEN** the system SHALL show that the invite does not exist or is no longer valid

### Requirement: Family changes preserve unrelated preferences
The system SHALL keep theme and reminder preferences intact when family sharing state changes.

#### Scenario: Member is added or removed
- **WHEN** a family member is added or removed successfully
- **THEN** the system SHALL NOT clear local theme skin cache or reminder settings cache

#### Scenario: Removed member returns to app
- **WHEN** a user who was removed from a family resumes the app and backend auth restoration indicates the family is no longer accessible
- **THEN** the system SHALL invalidate the old family access state and return the user to login or a reinitialization state
