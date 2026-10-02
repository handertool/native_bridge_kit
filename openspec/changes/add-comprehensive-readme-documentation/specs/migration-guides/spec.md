## ADDED Requirements

### Requirement: Migration guide from manual MethodChannel
docs/migrate-from-methodchannel.md SHALL provide side-by-side code comparisons showing how to replace manual MethodChannel implementation with native_bridge_kit for the same use case.

#### Scenario: Developer migrates method call
- **WHEN** developer reads the MethodChannel → native_bridge_kit section
- **THEN** they see: before (manual MethodChannel setup) and after (native_bridge_kit contract and generated code)

#### Scenario: Developer migrates stream
- **WHEN** developer reads the EventChannel migration section
- **THEN** they see: before (manual EventChannel) and after (native_bridge_kit Stream)

#### Scenario: Developer understands benefits
- **WHEN** developer reads the migration guide
- **THEN** they see: lines of code reduced, type safety gained, error handling simplified

### Requirement: Migration guide includes step-by-step instructions
The MethodChannel migration guide SHALL provide numbered steps to convert an existing manual implementation to native_bridge_kit.

#### Scenario: Developer follows step-by-step
- **WHEN** developer follows the migration steps
- **THEN** they can migrate a working MethodChannel implementation in 15 minutes

#### Scenario: Developer verifies migration worked
- **WHEN** developer completes migration steps
- **THEN** they see: verification checkpoint showing tests still pass

### Requirement: Migration guide from Pigeon
docs/migrate-from-pigeon.md SHALL provide side-by-side code comparisons and migration steps for developers moving from Pigeon to native_bridge_kit.

#### Scenario: Developer migrates Pigeon contract
- **WHEN** developer reads the Pigeon migration section
- **THEN** they see: Pigeon .dart API definition vs. native_bridge_kit contract

#### Scenario: Developer understands Pigeon differences
- **WHEN** developer reads the guide
- **THEN** they understand: Pigeon requires separate API file; native_bridge_kit uses Dart contract as single source of truth

#### Scenario: Developer migrates step-by-step
- **WHEN** developer follows the Pigeon migration steps
- **THEN** they can migrate a Pigeon plugin in 20 minutes

### Requirement: Migration guides include gotchas and differences
Both migration guides SHALL highlight important differences, gotchas, and things to watch out for.

#### Scenario: Developer avoids common mistakes
- **WHEN** developer reads the gotchas section
- **THEN** they see: common errors (wrong naming conventions, missed error handling, etc.)

#### Scenario: Developer understands benefits
- **WHEN** developer reads comparison
- **THEN** they see: native_bridge_kit advantages (type safety, MockBridgeTransport, drift-check)

### Requirement: Migration rollback guidance
The migration guides SHALL explain how to keep both old and new implementations during migration for gradual rollout.

#### Scenario: Developer migrates gradually
- **WHEN** developer reads gradual migration section
- **THEN** they see: how to have MethodChannel and native_bridge_kit bridge coexist
