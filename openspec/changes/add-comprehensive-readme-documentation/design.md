## Context

The native_bridge_kit project has completed implementation of Kotlin/Swift generators, drift-check CLI, and MockBridgeTransport enhancements. The codebase is production-ready but lacks comprehensive user-facing documentation. Developers need clear installation, setup, and usage guides to adopt the framework. Documentation will be published alongside the v0.1 release on pub.dev.

Current state:
- 4 new packages (native_bridge_kit_android_gen, native_bridge_kit_ios_gen, native_bridge_kit_cli, and enhancements to native_bridge_kit)
- Complete API surface but minimal user documentation
- Example contracts exist but no complete sample projects
- No step-by-step guides or migration paths

Stakeholders:
- **End developers**: Need clear getting-started guides and API references
- **Platform teams**: Need installation and environment setup docs
- **Migrating users**: Coming from manual MethodChannel or Pigeon
- **Pub.dev users**: Judge adoption readiness by documentation quality

## Goals / Non-Goals

**Goals:**
- Provide clear installation instructions for all packages
- Deliver step-by-step getting-started guide (10-minute quickstart)
- Document complete API surface (annotations, MockBridgeTransport, drift-check CLI)
- Guide Dart unit testing with MockBridgeTransport
- Enable migration from MethodChannel and Pigeon
- Troubleshoot common errors and setup issues
- Include runnable example projects with unit tests
- Support all platforms (macOS, Linux, Windows; Android, iOS)
- Professional quality documentation for pub.dev

**Non-Goals:**
- Deep dives into Flutter internals or MethodChannel implementation
- Performance benchmarking or comparison studies
- Advanced topics (custom serialization, FFI integration) - defer to Phase 2
- Video tutorials or interactive guides
- Localization to other languages

## Decisions

### Decision 1: Documentation Structure - Hierarchical with Package-Level READMEs
**Rationale**: Each package is independently installable and has different users (generator users vs. CLI users). Per-package READMEs allow developers to find relevant docs without searching multiple files.

**Approach**:
- Root `README.md`: Project overview, architecture diagram, quick links
- Per-package READMEs: `packages/*/README.md` with package-specific setup
- Centralized guides: `/docs/getting-started.md`, `/docs/api-reference.md`, etc.
- Example projects: `/examples/android-ios-sample` with complete runnable code

**Alternatives considered**:
- Single monolithic README: Rejected - too large, hard to navigate
- Wiki pages: Rejected - fragmented, harder to version control with code

### Decision 2: Getting-Started Approach - Guided Workshop Format
**Rationale**: Users learn best by doing. A guided 10-minute walkthrough builds credibility and reduces barriers to entry.

**Approach**:
- Start with a minimal contract (DeviceInfo bridge)
- Show Dart code generation step-by-step
- Demonstrate Android handler implementation
- Demonstrate iOS handler implementation
- Show Dart unit test with MockBridgeTransport (no native platform)
- Build and run on simulator/device

**Alternatives considered**:
- API reference first: Rejected - too dry for first-time users
- Video tutorials only: Rejected - not accessible offline or in text form
- Separate Android/iOS guides: Rejected - developers want both platform context

### Decision 3: Documentation Format - Markdown in Repo with Code Examples
**Rationale**: Markdown files version-controlled with code make docs easy to update and keep in sync with implementation. Embedded code examples can be verified to compile.

**Approach**:
- All docs in `/docs` and `README.md` files as Markdown
- Code examples embedded inline with language markers
- Example projects in `/examples` - complete, runnable, tested
- Use GitHub markdown features for clarity

**Alternatives considered**:
- External wiki/documentation site: Rejected - hard to keep in sync
- API docs only (dartdoc comments): Rejected - loses narrative flow
- PDF guides: Rejected - harder to update and version

### Decision 4: Example Projects - Complete Android+iOS Sample Apps
**Rationale**: Developers learn by copy-paste and modification. Complete working examples reduce friction and prove the tooling works end-to-end.

**Approach**:
- Create `/examples/device-info-app`: Full Android+iOS app using DeviceInfo bridge
- Includes Kotlin handlers and Swift handlers (USER CODE filled in)
- Includes complete Dart unit test suite (using MockBridgeTransport)
- Includes integration tests (using MethodChannelTransport)
- Can be built and run directly: `flutter run`

**Alternatives considered**:
- Minimal stubs only: Rejected - doesn't prove it works
- Separate Android and iOS examples: Rejected - developers want full picture

### Decision 5: API Reference - Auto-Generated + Manual Curation
**Rationale**: Dartdoc generates accurate API docs, but needs narrative context and usage patterns to be useful.

**Approach**:
- dartdoc comments in source code for all public APIs
- Manual API reference guide in `/docs/api-reference.md` with examples
- Annotation reference with @NativeBridge, @NativeMethod, @NativeStream examples
- MockBridgeTransport API with test patterns
- drift-check CLI with all flags and usage

**Alternatives considered**:
- Dartdoc only: Rejected - lacks usage patterns and context
- Manual docs only: Rejected - harder to keep in sync with code

### Decision 6: Dart Unit Testing Focus - MockBridgeTransport as First-Class
**Rationale**: Testability was a core requirement. Unit testing guide must demonstrate that developers don't need native platform for testing bridge code.

**Approach**:
- Dedicated `/docs/testing-guide.md` with comprehensive patterns
- Show Future, Stream, error testing with MockBridgeTransport
- Compare unit tests (MockBridgeTransport) vs. integration tests (real native)
- Include test examples from DeviceInfo bridge
- CI/CD integration for test reporting

**Alternatives considered**:
- Testing as subsection of general guide: Rejected - deserves prominence
- Integration testing only: Rejected - contradicts testability claim

### Decision 7: Migration Paths - Side-by-Side Comparisons
**Rationale**: Developers coming from MethodChannel or Pigeon need concrete examples of how to migrate, not just abstract concepts.

**Approach**:
- Separate migration guides: `/docs/migrate-from-methodchannel.md`, `/docs/migrate-from-pigeon.md`
- Show before/after code for same feature
- Highlight benefits and gotchas
- Example: "How to migrate your device info plugin in 15 minutes"

**Alternatives considered**:
- Generic migration principles: Rejected - too abstract
- Combined into main guide: Rejected - adds noise for new users

## Risks / Trade-offs

| Risk | Mitigation |
|------|-----------|
| Documentation becomes outdated as code changes | Review and update docs with every code change; CI/CD checks for broken docs links and invalid code examples |
| Too much documentation overwhelms new users | Provide clear entry points: "Start here →" links; progressive disclosure (basic first, advanced later) |
| Example projects are too simple to be realistic | Create complete example with error handling, logging, comments; make it production-adjacent |
| Missing edge cases in guides | Solicit feedback from beta users; iterate based on support questions |
| Platform-specific setup complexity | Create platform-specific guides; provide troubleshooting for common errors |
| Maintaining code examples in docs | Use external example files that are tested as part of CI, not copied snippets |

## Migration Plan

1. **Phase 1: Core Documentation** (this change)
   - Write getting-started guide
   - Create per-package READMEs
   - Build example project

2. **Phase 2: Publication** (after this change is implemented)
   - Publish to main `README.md`
   - Verify all links work
   - Submit example projects to pub.dev showcase

3. **Phase 3: Community Feedback** (post-release)
   - Monitor GitHub issues for "how do I...?" questions
   - Update guides based on common questions
   - Add FAQ section as questions accumulate

4. **Rollback**: Documentation is non-breaking; revert commits if content is wrong

## Open Questions

1. Should we create a formal API reference site (like docs.rs or api.flutter.dev) or keep everything in Markdown?
   - **Recommendation**: Start with Markdown; evaluate dedicated site based on usage
2. How many example projects for different use cases? (just DeviceInfo or also others?)
   - **Recommendation**: Start with DeviceInfo; add others based on user requests
3. Should troubleshooting guide be a separate doc or integrated into each guide?
   - **Recommendation**: Start as separate `/docs/troubleshooting.md`; can consolidate later
