## ADDED Requirements

### Requirement: Getting-started guide walkthrough
docs/getting-started.md SHALL provide a complete 10-minute walkthrough for new users to go from Dart contract to working app with Dart unit tests, without requiring native platform setup.

#### Scenario: Developer completes getting-started guide
- **WHEN** a developer follows the getting-started guide step-by-step
- **THEN** they can define a Dart contract, generate code, and run Dart unit tests in <10 minutes

#### Scenario: Guide includes concrete example
- **WHEN** developer reads getting-started guide
- **THEN** it shows complete code for: contract definition, generated Dart code, handler stubs, and unit tests

#### Scenario: Developer doesn't need native platform
- **WHEN** developer follows getting-started steps
- **THEN** they can run all tests with `flutter test` without iOS/Android setup

### Requirement: Step-by-step walkthrough sections
The getting-started guide SHALL include numbered steps: Define Contract → Generate → Implement Handlers → Write Tests → Build App.

#### Scenario: Each step is completable
- **WHEN** developer completes step N
- **THEN** step N+1 builds on the previous result without gaps or missing context

#### Scenario: Code examples are copy-pasteable
- **WHEN** developer copy-pastes code from the guide
- **THEN** the code compiles and works without modification

### Requirement: Dart unit testing emphasis
The getting-started guide SHALL highlight that developers can unit test bridge code using MockBridgeTransport without native platform compilation.

#### Scenario: Unit testing section shows MockBridgeTransport usage
- **WHEN** developer reads the testing section
- **THEN** they see: `transport.stubMethod()`, `transport.stubStream()`, and example assertions

#### Scenario: Developer sees test without native platform
- **WHEN** developer reads getting-started tests
- **THEN** all example tests use MockBridgeTransport and can run with `flutter test`

### Requirement: Time guidance and checkpoints
The getting-started guide SHALL include time estimates for each section and completion checkpoints.

#### Scenario: Developer tracks progress
- **WHEN** developer follows getting-started guide
- **THEN** each section starts with "⏱️ ~2 minutes" and ends with a verification checkpoint

#### Scenario: Developer can skip to advanced sections
- **WHEN** developer has prior experience
- **THEN** they can skip early sections and jump to "just show me the code" section
