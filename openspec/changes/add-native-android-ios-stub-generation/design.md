## Context

Currently, native_bridge_kit generates only Dart-side typed clients from Dart contracts. Developers must manually implement native handlers in Kotlin (Android) and Swift (iOS), matching channel names and method signatures by hand. This creates:

- **Manual sync burden**: contract changes don't automatically propagate to native stubs
- **Type inconsistency**: no guarantee parameter types match across Dart and native
- **Boilerplate**: repetitive MethodChannel registration and method dispatch code
- **Learning curve**: new developers must understand channel naming conventions and error handling patterns

We have a working foundation: abstract contract classes, annotations, build_runner generator, runtime transport abstraction, and MethodChannel transport. The missing piece is native code generation for Kotlin and Swift.

## Goals / Non-Goals

**Goals:**
- Generate Kotlin handlers from Dart contracts that handle MethodChannel dispatch, argument extraction, and error mapping
- Generate Swift handlers from Dart contracts following iOS conventions and EventChannel patterns
- Provide drift-check tool to catch contract/native mismatch during dev time
- Maintain single source of truth: Dart contract is authoritative
- Minimize manual native code; focus on business logic only
- Support Future<T> and Stream<T> return types in v0.1
- Support common Dart types (String, int, double, bool, List, Map) with optional adapter pattern for custom types

**Non-Goals:**
- Generate FFI bindings or C bridges in v0.1
- Support positional parameters (named only, matching Dart generator)
- Auto-generate Dart codecs for custom types (manual adapters expected)
- Platform-specific performance optimization (generic, portable approach)
- Backward compatibility with pre-announcement native code (breaking accepted for v0.0→v0.1)
- Web, Windows, macOS, Linux platforms in v0.1

## Decisions

### 1. Kotlin and Swift generators as separate packages

**Decision**: Create native_bridge_kit_android_gen and native_bridge_kit_ios_gen as separate packages with own build.yaml registrations.

**Rationale**:
- Android and iOS have distinct toolchains, conventions, and dependency graphs
- Decoupling keeps each generator focused and testable
- Allows independent versioning and release cadence
- Developers on iOS-only projects don't pull Android dependencies

**Alternatives considered**:
- Single monolithic generator: would be tightly coupled, harder to maintain and test independently
- Template-based codegen: would sacrifice type safety in generated handlers

### 2. Type mapping strategy via annotations

**Decision**: Extend `@NativeBridge` annotation to accept optional `typeMapping` field mapping Dart types to native types (e.g., `DateTime` → `java.time.Instant` or `Date`).

**Rationale**:
- Explicit, declarative mapping avoids magic or heuristics
- Developers with custom types have a clear escape hatch
- Keeps generated code predictable and reviewable
- Composable: multiple type mappings for different platforms

**Alternatives considered**:
- Auto-infer from type names: error-prone and too magical
- Plugin system for type handlers: premature complexity for v0.1
- Only support primitive types: too limiting

### 3. Generated code safety: preserve manual edits

**Decision**: Generated Kotlin and Swift handlers include clear block delimiters (comments/pragma) for manual business logic; regeneration respects these blocks.

Example Kotlin:
```kotlin
fun myMethod(args: Map<String, Any?>, result: MethodChannel.Result) {
  // BEGIN USER CODE
  // Edit here; this block is preserved across regenerations
  result.notImplemented()
  // END USER CODE
}
```

**Rationale**:
- Developers can safely regenerate after contract changes
- Business logic is explicitly protected from overwrite
- Reduces friction when adding new methods to contract

**Alternatives considered**:
- Never regenerate once created: loses sync opportunity and defeats single-source-of-truth
- Overwrite everything: loses manual logic and business code

### 4. Drift checking via CLI command

**Decision**: Add `openspec drift-check --change <name>` command that validates Dart contract matches generated native stubs by:
1. Parsing Dart AST to extract method names, parameter names, and types
2. Parsing generated Kotlin/Swift files to extract same metadata
3. Comparing and reporting mismatches (missing methods, wrong types, missing parameters)

**Rationale**:
- Dev-time, not runtime: fast feedback loop
- Non-blocking in CI (advisory, not fail-hard) for v0.1; can be fail-hard in CI config
- Composable with other checks and builds

**Alternatives considered**:
- Runtime validation at app startup: too late, poor UX for developers
- Just-in-time generation on each build: slower, noisier, not reproducible
- Manual sync checks via docs: unreliable, human error prone

### 5. Channel naming convention

**Decision**: Use `snake_case` class name as channel prefix; method names are `snake_case` method names.

Example: `DeviceInfoBridge` class with `getModel()` method → channel `device_info_bridge`, method `get_model`.

**Rationale**:
- Predictable and consistent with current Dart implementation
- Matches Dart snake_case conventions
- Avoids ambiguity in multi-word names (e.g., "XMLParser" → "xml_parser")

### 6. Error handling and type conversion

**Decision**: Use try-catch in generated handlers; errors are caught and mapped to platform-native exceptions (PlatformException in Kotlin, FlutterMethodChannel error handling in Swift).

Custom types require optional adapter functions developers provide inline.

**Rationale**:
- Consistent error reporting across platforms
- Developers focus on business logic, not error marshalling
- Adapter pattern is explicit and type-safe

**Alternatives considered**:
- Auto-serialize custom types: implies codecs, too complex for v0.1
- Panic on unknown types: poor UX when contract includes custom types

## Testing Strategy

### Dart-First Unit Testing

Generated bridge code is designed to be **fully testable in Dart without native platform setup**:

1. **MockBridgeTransport**: Developers stub method responses and stream events using fluent API
   ```dart
   final transport = MockBridgeTransport();
   transport.stubMethod('device_info', 'get_model', (_) => 'iPhone 99');

   final bridge = DeviceInfoBridge(transport);
   final model = await bridge.getModel(); // Returns 'iPhone 99'
   expect(model, 'iPhone 99');
   ```

2. **Testable contract**: Since the contract is the source of truth, generated handlers are inherently verifiable via drift-check and unit tests. If the Dart contract changes, regenerated Kotlin/Swift stubs will always match.

3. **Test coverage**: Each bridge capability can be unit tested in Dart:
   - Future methods: stub responses, verify parameter passing, error handling
   - Stream methods: emit test events, verify subscription/cancellation
   - Error cases: stub exceptions, verify PlatformException mapping

4. **Golden tests**: Generated handler templates can include golden test fixtures showing expected channel traffic and argument schemas.

### Native Platform Testing

Native developers write unit tests for business logic within USER CODE blocks; the bridge dispatch layer is auto-verified by drift-check.

### Integration Testing

Full end-to-end: sample app runs on real device/simulator, executes bridge calls, verifies native ↔ Dart message flow.

## Risks / Trade-offs

| Risk | Mitigation |
|------|-----------|
| Generated code becomes out of sync with contract | Drift-check command catches mismatches; integrate into dev workflow docs |
| Developer manually edits generated code outside user blocks | Clear documentation + templates showing safe edit patterns; code review |
| Type mapping errors (Dart `int` → Kotlin `String` accidentally) | TypeScript-like annotation review; test with sample payloads |
| Kotlin/Swift generator maintenance burden as languages evolve | Isolate language-specific logic to separate packages; unit tests per platform |
| Generated code is verbose or "feels wrong" to native developers | Invest in readable templates; show sample output in docs; gather feedback |
| Future transport swap (Phase 3) requires native generator refactor | Use platform-neutral method/args design now; transport detail isolated to handler invocation |
| Dart unit tests don't catch native-side bugs | Document expectation: Dart tests verify contract; integration/native tests verify business logic |

## Migration Plan

**Phase 1 (now - v0.1)**: Dart client generation (already shipped), intro native stub generation, drift check

**Phase 2 (post-v0.1)**:
- Pluggable transport API stabilization (e.g., NativePort transport for Dart isolate bridges)
- Auto-regenerate in watch mode for dev loop
- Enhanced test template generation

**Phase 3 (future)**:
- FFI bridges as alternative to MethodChannel
- Async native handlers (Kotlin coroutines, Swift structured concurrency)
- Pub.dev adoption metrics and feedback iteration

**Rollout**:
- Canary: release to early adopters in beta on pub.dev, gather native developer feedback
- Stable: v0.1 release after feedback iteration, includes Android+iOS samples
- Docs: migration guide from manual MethodChannel

## Open Questions

1. Should drift-check fail CI by default or just warn? → Recommend warn in v0.1, allow config per project
2. Should generated Kotlin/Swift files be committed to git or gitignored like Dart `.g.dart`? → Recommend git (easier to review diffs in code reviews) but document build-time regeneration option
3. How to handle platform-specific types (e.g., `File`, `Uri`)? → v0.1: custom adapters; future: stdlib mappings
4. Should tests be generated alongside native stubs? → Future phase; v0.1 focus on handler scaffolding only
