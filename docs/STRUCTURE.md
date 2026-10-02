# Documentation Structure

This document outlines the directory structure and navigation for the native_bridge_kit documentation.

## Directory Layout

```
docs/
├── getting-started.md           # contract and generation walkthrough
├── installation.md              # Platform-specific installation guide
├── api-reference.md             # Complete API documentation
├── testing-guide.md             # Dart unit testing with MockBridgeTransport
├── migrate-from-methodchannel.md # Migration from manual MethodChannel
├── migrate-from-pigeon.md       # Migration from Pigeon
└── troubleshooting.md           # Common issues and FAQ

packages/native_bridge_kit_gen/
└── README.md                    # Core package documentation

packages/native_bridge_kit_android_gen/
└── README.md                    # Android Kotlin generator documentation

packages/native_bridge_kit_ios_gen/
└── README.md                    # iOS Swift generator documentation

packages/native_bridge_kit_cli/
└── README.md                    # CLI tools and drift-check documentation

examples/device-info-app/        # Complete working example with tests
├── lib/
├── android/
├── ios/
├── test/
├── integration_test/
└── README.md
```

## Navigation Quick Links

### For New Users
1. Start: [Root README.md](../README.md) — Overview and quick links
2. Next: [Installation Guide](installation.md) — Platform-specific setup
3. Then: [Getting Started Guide](getting-started.md) — contract and generation walkthrough
4. Practice: [Example Project](../examples/device-info-app) — Complete working app

### For Developers
- [API Reference](api-reference.md) — Annotations, MockBridgeTransport, drift-check
- [Testing Guide](testing-guide.md) — Unit testing patterns and CI/CD
- [Troubleshooting](troubleshooting.md) — Common errors and solutions

### For Migration
- [From MethodChannel](migrate-from-methodchannel.md) — Step-by-step conversion
- [From Pigeon](migrate-from-pigeon.md) — Feature comparison and migration

## Documentation Standards

All documentation follows these principles:
- **Copy-pasteable code**: All code examples must compile and work
- **Platform coverage**: macOS, Linux, Windows setup instructions
- **Clear structure**: Step-by-step sections with time estimates
- **Verification checkpoints**: Each section has a "Verify it worked" step
- **Links between docs**: Navigation between related topics
- **Examples everywhere**: Each concept includes working code
