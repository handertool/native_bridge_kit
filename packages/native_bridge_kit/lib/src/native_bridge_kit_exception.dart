/// Typed exception raised when the native side signals an error through a
/// [PlatformException].
///
/// All fields mirror the [PlatformException] surface so callers can pattern-
/// match on [code] without having to import `package:flutter/services.dart`.
class NativeBridgeException implements Exception {
  const NativeBridgeException({
    required this.code,
    this.message,
    this.details,
  });

  /// The error code returned by the native handler (e.g. `"PERMISSION_DENIED"`).
  final String code;

  /// Optional human-readable description.
  final String? message;

  /// Optional platform-specific detail object (usually a `Map` or `String`).
  final Object? details;

  @override
  String toString() =>
      'NativeBridgeException(code: $code, message: $message, details: $details)';
}
