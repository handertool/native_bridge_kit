## 1. Project Setup and Package Structure

- [x] 1.1 Create `packages/native_bridge_kit_android_gen` package with pubspec.yaml
- [x] 1.2 Create `packages/native_bridge_kit_ios_gen` package with pubspec.yaml
- [x] 1.3 Add analyzer, build, source_gen dependencies to both generator packages
- [x] 1.4 Create build.yaml for Android generator with SharedPartBuilder configuration
- [x] 1.5 Create build.yaml for iOS generator with SharedPartBuilder configuration
- [x] 1.6 Update main project pubspec.yaml to include both generators as dev_dependencies
- [x] 1.7 Create directory structure for generator lib/src files and test directories

## 2. Android Kotlin Generator Implementation

- [x] 2.1 Create KotlinBridgeGenerator class extending GeneratorForAnnotation<NativeBridge>
- [x] 2.2 Implement Dart contract parser to extract method signatures, return types, parameters
- [x] 2.3 Implement Kotlin type mapper (Dart String → Kotlin String, Dart int → Kotlin Int, etc.)
- [x] 2.4 Implement code emitter for MethodChannel registration and method dispatch switch
- [x] 2.5 Implement Future<T> handler generation with try-catch and error mapping
- [x] 2.6 Implement Stream<T> handler generation with EventChannel and onListen/onCancel
- [x] 2.7 Implement USER CODE block preservation across regenerations (BEGIN/END markers)
- [x] 2.8 Add support for custom type mappings via annotation fields
- [ ] 2.9 Write unit tests for Kotlin type mapping edge cases (nullable, List, Map)
- [ ] 2.10 Write integration test: generate handler for sample contract, verify Kotlin syntax validity
- [x] 2.11 Create example `device_info_handler.kt` showing generated output and USER CODE patterns
- [x] 2.12 Test build_runner integration: run `build_runner build` and verify .g.dart and .kt files generated

## 3. iOS Swift Generator Implementation

- [x] 3.1 Create SwiftBridgeGenerator class extending GeneratorForAnnotation<NativeBridge>
- [x] 3.2 Implement Dart contract parser to extract method signatures, return types, parameters
- [x] 3.3 Implement Swift type mapper (Dart String → Swift String, Dart int → Swift Int, etc.)
- [x] 3.4 Implement code emitter for FlutterMethodChannel registration and method dispatch
- [x] 3.5 Implement Future<T> handler generation with try-catch and error mapping
- [x] 3.6 Implement Stream<T> handler generation with FlutterEventChannel and StreamHandler
- [x] 3.7 Implement USER CODE block preservation across regenerations (MARK comments)
- [x] 3.8 Add support for custom type mappings via annotation fields
- [ ] 3.9 Write unit tests for Swift type mapping edge cases (optional, Array, Dictionary)
- [ ] 3.10 Write integration test: generate handler for sample contract, verify Swift syntax validity
- [x] 3.11 Create example `DeviceInfoHandler.swift` showing generated output and USER CODE patterns
- [x] 3.12 Test build_runner integration: run `build_runner build` and verify .g.dart and .swift files generated

## 4. Drift Check Command Implementation

- [x] 4.1 Create native_bridge_kit_cli package (or add CLI support to native_bridge_kit_gen)
- [x] 4.2 Implement Dart AST parser to extract bridge contract metadata (methods, parameters, types)
- [x] 4.3 Implement Kotlin source parser to extract handler metadata (methods, parameters, types)
- [x] 4.4 Implement Swift source parser to extract handler metadata (methods, parameters, types)
- [x] 4.5 Implement drift comparison logic: detect missing methods, parameter mismatches, type mismatches
- [x] 4.6 Implement human-readable output formatter with clear issue descriptions
- [x] 4.7 Implement JSON output formatter for CI integration
- [x] 4.8 Add --platform flag to filter Android/iOS checks
- [x] 4.9 Add --fail-on-drift flag for CI integration (exit code 1 on issues)
- [x] 4.10 Write unit tests for drift detection logic with various mismatch scenarios
- [x] 4.11 Write end-to-end test: create contract, generate handlers, introduce drift, run drift-check, verify detection
- [x] 4.12 Add drift-check command to build script documentation

## 5. Type Mapping and Custom Type Support

- [x] 5.1 Extend @NativeBridge annotation to include optional `typeMapping` field
- [x] 5.2 Create TypeMapping class to parse and validate type mapping rules
- [x] 5.3 Update Kotlin generator to use custom type mappings when available
- [x] 5.4 Update Swift generator to use custom type mappings when available
- [x] 5.5 Add error handling for unsupported types (fail with helpful guidance)
- [x] 5.6 Create type mapping documentation with examples (DateTime, Uri, File, custom classes)
- [x] 5.7 Write tests for type mapping edge cases (nested generics, nullable custom types)

## 6. Error Handling and Exception Mapping

- [x] 6.1 Update Kotlin generator to wrap method logic in try-catch with PlatformException mapping
- [x] 6.2 Update Swift generator to wrap method logic in try-catch with FlutterError mapping
- [x] 6.3 Create error handling documentation with examples for common exception types
- [x] 6.4 Add error codes reference guide for both platforms
- [x] 6.5 Write tests for error propagation (verify Dart client receives PlatformException with correct code)

## 7. Testing and Quality Assurance

### Generator and Infrastructure Tests

- [x] 7.1 Create comprehensive unit test suite for Dart contract parser
- [ ] 7.2 Create unit test suite for Kotlin code generation
- [ ] 7.3 Create unit test suite for Swift code generation
- [ ] 7.4 Create integration test for Android handler compilation and runtime behavior (if possible in test environment)
- [ ] 7.5 Create integration test for iOS handler compilation and runtime behavior (if possible in test environment)
- [x] 7.6 Test full circle: define contract → generate code → verify generated code matches spec requirements
- [x] 7.7 Test generator robustness: edge cases (empty contracts, very long method names, special characters)
- [x] 7.8 Add code coverage measurements to generator packages (target >80%)
- [x] 7.9 Create linting rules for generated code quality (if applicable)

### Dart Unit Testing with MockBridgeTransport

- [x] 7.10 Enhance MockBridgeTransport with fluent builder API for stubbing methods and streams
- [x] 7.11 Add MockBridgeTransport helper methods: `stubMethod(channel, method, handler)`, `stubStream(channel, stream)`, `captureInvocations()` for assertion
- [x] 7.12 Create example Dart unit test file showing how to test DeviceInfoBridge using MockBridgeTransport
- [x] 7.13 Test Future methods: stub responses, verify parameters passed, test error handling
- [x] 7.14 Test Stream methods: emit test events, verify subscription, test cancellation
- [x] 7.15 Test error cases: stub exceptions, verify Dart receives PlatformException with correct code/message
- [x] 7.16 Create Dart unit tests for all sample contracts (DeviceInfoBridge example tests included)
- [x] 7.17 Verify Dart tests run without native platform (pure Dart test suite, `flutter test` only)

### Contract and Drift Validation Tests

- [x] 7.18 Create unit tests for drift-check command (parser accuracy, comparison logic)
- [x] 7.19 Test drift-check against generated Kotlin code: detect missing methods, parameter mismatches
- [x] 7.20 Test drift-check against generated Swift code: detect missing methods, parameter mismatches
- [x] 7.21 Test drift-check JSON output parsing and CI integration
- [x] 7.22 Create end-to-end test: modify contract, regenerate, verify drift-check detects changes
- [x] 7.23 Test drift-check platform filtering (--platform android, --platform ios, --platform all)

### Integration and End-to-End Tests

- [x] 7.24 Create end-to-end sample project: contract → generate Dart/Kotlin/Swift → build Android apk
- [x] 7.25 Create end-to-end sample project: contract → generate Dart/Swift → build iOS app
- [x] 7.26 Verify end-to-end projects can call native methods and receive responses on real device/simulator
- [x] 7.27 Verify end-to-end projects can subscribe to native streams on real device/simulator
- [x] 7.28 Verify error propagation end-to-end: native exception → PlatformException → Dart catch block
- [x] 7.29 Verify testability claim: demonstrate Dart unit tests for same bridge pass without native platform

## 8. Documentation and Samples

### Sample Plugins and Getting Started

- [x] 8.1 Create sample Android plugin using native_bridge_kit (complete with contract, handlers, build setup)
- [x] 8.2 Create sample iOS plugin using native_bridge_kit (complete with contract, handlers, Xcode setup)
- [x] 8.3 Write getting started guide: "Generate your first Android+iOS plugin in 10 minutes"
- [x] 8.4 Create architecture diagram showing contract → generators → Dart/Kotlin/Swift flow

### Dart Unit Testing Documentation

- [x] 8.5 Create comprehensive "Dart Unit Testing Guide" with MockBridgeTransport examples
  - Section 1: Overview of testability (test without native platform)
  - Section 2: MockBridgeTransport API reference
  - Section 3: Example unit tests for Future methods
  - Section 4: Example unit tests for Stream methods
  - Section 5: Testing error cases
  - Section 6: Integration with CI/CD (coverage, test reporting)
- [x] 8.6 Include complete working example: DeviceInfoBridge unit tests file with >10 test cases
- [x] 8.7 Add example showing how to test Dart business logic without native platform
- [x] 8.8 Document best practices: mocking, test structure, assertions for streams and futures

### Type Mapping and Error Handling

- [x] 8.9 Document type mapping rules and supported types for each platform
- [x] 8.10 Document drift-check command usage and CI integration
- [x] 8.11 Create error handling guide: common exception types, custom error codes, propagation examples

### Migration Guides and API Reference

- [x] 8.12 Write migration guide for developers coming from manual MethodChannel
- [x] 8.13 Write migration guide for developers coming from Pigeon
- [x] 8.14 Create API reference documentation for all annotations (@NativeBridge, @NativeMethod, @NativeStream, typeMapping)
- [x] 8.15 Document best practices: naming conventions, error handling, testing strategies
- [x] 8.16 Create troubleshooting guide: common issues and solutions

## 9. Build and Release Preparation

- [x] 9.1 Add GitHub Actions CI workflow to build generators and run tests on each PR
- [x] 9.2 Set up code coverage reporting (e.g., Codecov)
- [x] 9.3 Create CHANGELOG entries for v0.1 release
- [x] 9.4 Verify all pub.dev publish requirements (docs, tests, license, CHANGELOG)
- [x] 9.5 Create README for each generator package with clear description and setup instructions
- [x] 9.6 Add example usage snippets to all package READMEs
- [x] 9.7 Verify generated code licenses and attribution (e.g., builder comments showing tool version)
- [x] 9.8 Test pub.dev dry-run publish for each package

## 10. Validation and Acceptance Testing

### End-to-End Platform Validation

- [x] 10.1 Create a complete Android+iOS sample app that builds and runs successfully
- [x] 10.2 Verify sample app can successfully call native methods and receive responses
- [x] 10.3 Verify sample app can successfully subscribe to native event streams
- [x] 10.4 Test drift-check integration with CI (fail build on mismatch)

### Dart Unit Testing Validation

- [x] 10.5 Verify sample app includes Dart unit tests that run without native platform
- [x] 10.6 Verify MockBridgeTransport passes all test cases (methods, streams, errors)
- [x] 10.7 Demonstrate: same Dart test code works both with MockBridgeTransport (unit tests) and MethodChannelTransport (integration tests)
- [x] 10.8 Verify test coverage: document % of bridge code coverable by unit tests (target >90%)

### Quality and Documentation Validation

- [x] 10.9 Validate all documentation is accurate and examples run without errors
- [x] 10.10 Review generated code quality: readability, maintainability, consistency with Dart code generator
- [x] 10.11 Verify generated Dart code includes helpful comments on testability and MockBridgeTransport usage

### Final Acceptance Criteria

- [x] 10.12 Acceptance criteria: complete end-to-end workflow from contract to runnable plugin with unit tests
- [x] 10.13 Acceptance criteria: developer can unit test bridge code in Dart without any native compilation
- [x] 10.14 Acceptance criteria: Dart test examples included in documentation and sample projects

## 11. Extended Features for Future Phases

- [x] 11.1 Plan Phase 2: pluggable transport implementations (Dart isolate ports, FFI)
- [x] 11.2 Plan Phase 3: test code generation (unit test templates for handlers)
- [x] 11.3 Plan Phase 4: advanced type support (custom serialization, nested types)
- [x] 11.4 Document all future phases in roadmap document
