## ADDED Requirements

### Requirement: Annotation reference documentation
docs/api-reference.md SHALL document all annotation types (@NativeBridge, @NativeMethod, @NativeStream) with field descriptions and usage examples.

#### Scenario: Developer learns @NativeBridge annotation
- **WHEN** developer reads the annotation reference
- **THEN** they see: parameters, defaults, examples, and use cases for @NativeBridge

#### Scenario: Developer uses custom type mapping
- **WHEN** developer reads the annotation reference
- **THEN** they understand how to use typeMapping field with concrete examples

#### Scenario: Developer defines contract correctly
- **WHEN** developer follows annotation examples
- **THEN** their contract compiles and generates expected Dart/Kotlin/Swift code

### Requirement: MockBridgeTransport API reference
The API reference SHALL document all MockBridgeTransport methods with descriptions, parameters, return types, and code examples.

#### Scenario: Developer stubs a method
- **WHEN** developer reads MockBridgeTransport reference
- **THEN** they see: `stubMethod()`, `stubMethodValue()`, `stubMethodError()` with examples

#### Scenario: Developer stubs a stream
- **WHEN** developer reads MockBridgeTransport reference
- **THEN** they see: `stubStream()`, `stubStreamValue()`, `stubStreamError()` with examples

#### Scenario: Developer verifies method calls
- **WHEN** developer reads MockBridgeTransport reference
- **THEN** they see: `verifyMethodCalled()`, `captureInvocations()` with assertion examples

### Requirement: drift-check CLI reference
The API reference SHALL document the drift-check command with all available flags, exit codes, and usage examples for CI integration.

#### Scenario: Developer uses drift-check
- **WHEN** developer reads the drift-check CLI reference
- **THEN** they see: command syntax, all --flags, JSON output format, exit codes

#### Scenario: Developer integrates drift-check in CI
- **WHEN** developer reads the drift-check reference
- **THEN** they see: `--fail-on-drift` flag and example GitHub Actions workflow

#### Scenario: Developer parses JSON output
- **WHEN** developer reads the drift-check reference
- **THEN** they see: complete JSON schema with in_sync and issues fields

### Requirement: Type mapping reference
The API reference SHALL document supported types for Dart, Kotlin, and Swift conversions with examples of custom mappings.

#### Scenario: Developer checks type support
- **WHEN** developer reads the type mapping reference
- **THEN** they see: String, int, double, bool, List, Map, Future, Stream with examples

#### Scenario: Developer maps custom type
- **WHEN** developer reads custom type mapping section
- **THEN** they see: how to map DateTime, Uri, File, and custom classes

### Requirement: Error codes reference
The API reference SHALL document all error codes that can be thrown from handlers with descriptions and remediation steps.

#### Scenario: Developer handles errors
- **WHEN** developer reads the error codes reference
- **THEN** they see: error code names, meanings, and how to avoid them

#### Scenario: Developer debugs error
- **WHEN** developer sees an error code in logs
- **THEN** they can look it up in the reference and understand the cause
