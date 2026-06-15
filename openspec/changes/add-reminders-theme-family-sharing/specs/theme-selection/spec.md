## ADDED Requirements

### Requirement: Profile exposes theme selection
The system SHALL provide a theme and skin entry from the profile area that opens a theme selection screen.

#### Scenario: User opens theme selection
- **WHEN** a logged-in user taps the theme and skin entry in the profile area
- **THEN** the system SHALL navigate to a theme selection screen showing available skins, previews, and the current selection

#### Scenario: Profile shows current theme summary
- **WHEN** the profile area is displayed
- **THEN** the system SHALL show a summary of the currently selected theme skin

### Requirement: Theme skins are predefined and backend-compatible
The system SHALL support the `warm`, `fresh`, and `classic` theme skins as string enum values.

#### Scenario: Default theme is warm
- **WHEN** no cached or server theme preference exists
- **THEN** the system SHALL use the `warm` theme skin

#### Scenario: Theme skin is serialized
- **WHEN** theme preference is sent to or read from the backend
- **THEN** the system SHALL use the string values `warm`, `fresh`, and `classic`

#### Scenario: Invalid theme value is received
- **WHEN** cached or backend theme data contains an unsupported theme value
- **THEN** the system SHALL fall back to the `warm` theme skin

### Requirement: Theme changes apply immediately
The system SHALL apply selected theme skins to `MaterialApp.theme` without requiring an app restart.

#### Scenario: User selects a different theme
- **WHEN** the user taps a non-selected theme skin
- **THEN** the system SHALL update the active app theme immediately and mark that skin as selected

#### Scenario: Navigation state is preserved
- **WHEN** the active theme changes
- **THEN** the system SHALL preserve the current navigation route and existing form input state

### Requirement: Theme preference is locally persisted
The system SHALL store the selected theme skin locally for startup use.

#### Scenario: App starts with cached theme
- **WHEN** the app starts and a valid local theme skin exists
- **THEN** the system SHALL apply the cached theme before the user completes any manual theme selection

#### Scenario: User logs out
- **WHEN** the user logs out
- **THEN** the system SHALL NOT clear the locally cached theme preference

### Requirement: Theme preference syncs with backend
The system SHALL read and update theme preference through a typed preference service backed by `GET /api/preferences/theme` and `PATCH /api/preferences/theme`.

#### Scenario: Login synchronizes server preference
- **WHEN** a user logs in and the backend returns a theme preference
- **THEN** the system SHALL apply the server preference and update the local theme cache

#### Scenario: Theme update succeeds
- **WHEN** the user selects a theme and the backend saves it successfully
- **THEN** the system SHALL keep the selected theme and clear any theme sync error

#### Scenario: Theme update fails
- **WHEN** the backend fails to save the selected theme
- **THEN** the system SHALL keep the locally selected theme and expose an error state that can be shown by the UI
