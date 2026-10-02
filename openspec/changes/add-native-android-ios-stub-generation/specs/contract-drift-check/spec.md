## ADDED Requirements

### Requirement: Drift detection command

A new command `openspec drift-check` SHALL validate that a Dart bridge contract matches the generated Kotlin and Swift handler stubs. Command SHALL report mismatches (missing methods, incorrect parameter names, type mismatches) with actionable feedback to the developer.

#### Scenario: Detect missing method in native stubs
- **WHEN** Dart contract defines method `getBattery()` but Kotlin stub does not include handler for `get_battery`
- **THEN** drift-check reports: "Missing method 'get_battery' in Kotlin handler"

#### Scenario: Detect parameter mismatch
- **WHEN** Dart contract defines `getUserData({required int userId, String? filter})` but Kotlin stub expects only `userId`
- **THEN** drift-check reports: "Kotlin handler for 'get_user_data' missing parameter 'filter'"

#### Scenario: Detect type mismatch
- **WHEN** Dart contract defines `Future<int> getCount()` but Kotlin stub returns String
- **THEN** drift-check reports: "Type mismatch for method 'get_count': expected int, got String"

#### Scenario: Pass when contract and stubs are in sync
- **WHEN** Dart contract and both Kotlin and Swift stubs match (all methods, parameters, types present)
- **THEN** drift-check exits with status 0 and message "✓ Contract and stubs are in sync"

### Requirement: Drift check output and reporting

Drift-check SHALL parse Dart AST, Kotlin source, and Swift source to extract contract metadata. Output SHALL include:
- Count of drift issues found
- Detailed issue list with file paths and line numbers
- Suggested remediation (regenerate handlers)

#### Scenario: JSON output for CI integration
- **WHEN** drift-check is run with `--json` flag
- **THEN** output is valid JSON with structure: `{ "in_sync": bool, "issues": [{ "type": string, "method": string, "details": string }] }`

#### Scenario: Human-readable output for dev use
- **WHEN** drift-check is run without flags
- **THEN** output is formatted for terminal readability with colors/emphasis on errors

### Requirement: Integration with build process

Drift-check SHALL be integratable into CI/CD pipelines and can be configured to fail the build if drift is detected.

#### Scenario: Optional failure mode
- **WHEN** drift-check detects issues and is run in CI with `--fail-on-drift`
- **THEN** command exits with non-zero status code, failing the build

#### Scenario: Non-blocking warning mode
- **WHEN** drift-check detects issues and is run with default flags (no --fail-on-drift)
- **THEN** command exits with 0 but prints warnings

### Requirement: Scope and platform coverage

Drift-check SHALL support per-platform validation: check Kotlin only, Swift only, or both. Developer specifies target platforms.

#### Scenario: Check Android only
- **WHEN** drift-check is run with `--platform android`
- **THEN** only Kotlin stubs are validated against Dart contract

#### Scenario: Check both platforms
- **WHEN** drift-check is run with `--platform android --platform ios` or `--platform all`
- **THEN** both Kotlin and Swift stubs are validated
