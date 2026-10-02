import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:native_bridge_kit_annotation/native_bridge_kit_annotation.dart';
import 'package:source_gen/source_gen.dart';

import 'utils.dart';

/// Generates a concrete `_$ClassName` implementation for every abstract class
/// annotated with [@NativeBridge].
///
/// **Output pattern** (source-adjacent `.g.dart` via `SharedPartBuilder`):
/// ```dart
/// class _$DeviceInfoBridge extends DeviceInfoBridge with NativeBridgeBase {
///   _$DeviceInfoBridge(this.transport);
///
///   @override
///   final BridgeTransport transport;
///
///   @override
///   Future<String?> getModel() =>
///       transport.invoke<String>('device_info', 'get_model', const {});
///
///   @override
///   Stream<double> batteryLevel() =>
///       transport.listen<double>('device_info/battery_level');
/// }
/// ```
class NativeBridgeGenerator extends GeneratorForAnnotation<NativeBridge> {
  static const _nativeMethodChecker = TypeChecker.fromRuntime(NativeMethod);
  static const _nativeStreamChecker = TypeChecker.fromRuntime(NativeStream);

  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    // ── Validate the target element ─────────────────────────────────────────
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '@NativeBridge can only be applied to a class.',
        element: element,
      );
    }

    if (!element.isAbstract) {
      throw InvalidGenerationSourceError(
        '@NativeBridge class must be abstract. '
        'Make "${element.name}" abstract.',
        element: element,
      );
    }

    // ── Resolve channel prefix ───────────────────────────────────────────────
    final channelPrefixReader = annotation.read('channelPrefix');
    final channelPrefix = channelPrefixReader.isNull
        ? toSnakeCase(element.name)
        : channelPrefixReader.stringValue;

    final className = element.name;
    final generatedName = '_\$$className';
    final buffer = StringBuffer();

    // ── Class header ─────────────────────────────────────────────────────────
    buffer
      ..writeln(
        'class $generatedName with NativeBridgeBase implements $className {',
      )
      ..writeln('  $generatedName(this.transport);')
      ..writeln()
      ..writeln('  @override')
      ..writeln('  final BridgeTransport transport;');

    // ── Methods ───────────────────────────────────────────────────────────────
    for (final method in element.methods) {
      if (method.isStatic || method.isPrivate) continue;
      buffer.writeln();
      _writeMethod(buffer, method, channelPrefix);
    }

    buffer.writeln('}');
    return buffer.toString();
  }

  // ── Method dispatch ─────────────────────────────────────────────────────────

  void _writeMethod(
    StringBuffer buffer,
    MethodElement method,
    String channelPrefix,
  ) {
    final returnType = method.returnType;

    // Validate: only named parameters are supported.
    final positional = method.parameters.where((p) => !p.isNamed).toList();
    if (positional.isNotEmpty) {
      throw InvalidGenerationSourceError(
        'Method "${method.name}" has positional parameters '
        '(${positional.map((p) => p.name).join(', ')}). '
        'Only named parameters are supported by native_bridge_kit — they map '
        'directly to the named-arguments Map sent over the channel.',
        element: method,
      );
    }

    final wireName = _resolveWireName(method);

    if (_isStream(returnType)) {
      _writeStreamMethod(buffer, method, channelPrefix, wireName);
      return;
    }

    if (_isFuture(returnType)) {
      _writeFutureMethod(buffer, method, channelPrefix, wireName);
      return;
    }

    // Unsupported return type — emit a warning and skip, don't break the build.
    log.warning(
      '[@NativeBridge] Skipping "${method.name}": return type '
      '"$returnType" is not supported. '
      'Use Future<T> for one-shot calls or Stream<T> for event streams.',
    );
  }

  // ── Future<T> method ────────────────────────────────────────────────────────

  void _writeFutureMethod(
    StringBuffer buffer,
    MethodElement method,
    String channelPrefix,
    String wireName,
  ) {
    final innerType = _futureInnerType(method.returnType);
    final params = _buildParamList(method);
    final argsMap = _buildArgsMap(method);
    final returnTypeStr = _displayType(method.returnType);

    buffer
      ..writeln('  @override')
      ..writeln('  $returnTypeStr ${method.name}($params) =>')
      ..writeln(
        "      transport.invoke<$innerType>('$channelPrefix', '$wireName', $argsMap);",
      );
  }

  // ── Stream<T> method ────────────────────────────────────────────────────────

  void _writeStreamMethod(
    StringBuffer buffer,
    MethodElement method,
    String channelPrefix,
    String wireName,
  ) {
    final innerType = _streamInnerType(method.returnType);
    final channelName = '$channelPrefix/$wireName';
    final returnTypeStr = _displayType(method.returnType);

    buffer
      ..writeln('  @override')
      ..writeln('  $returnTypeStr ${method.name}() =>')
      ..writeln("      transport.listen<$innerType>('$channelName');");
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  /// Resolves the wire name from [@NativeMethod] / [@NativeStream] or falls
  /// back to the Dart method name converted to `snake_case`.
  String _resolveWireName(MethodElement method) {
    final methodAnnotation = _nativeMethodChecker.firstAnnotationOfExact(
      method,
    );
    if (methodAnnotation != null) {
      final nameReader = ConstantReader(methodAnnotation).read('name');
      return nameReader.isNull
          ? toSnakeCase(method.name)
          : nameReader.stringValue;
    }

    final streamAnnotation = _nativeStreamChecker.firstAnnotationOfExact(
      method,
    );
    if (streamAnnotation != null) {
      final nameReader = ConstantReader(streamAnnotation).read('name');
      return nameReader.isNull
          ? toSnakeCase(method.name)
          : nameReader.stringValue;
    }

    return toSnakeCase(method.name);
  }

  /// Emits `{required T name, T2 name2}` for the method signature — *named
  /// parameters only*.  Positional params are rejected earlier.
  String _buildParamList(MethodElement method) {
    final named = method.parameters;
    if (named.isEmpty) return '';
    final parts = named
        .map((p) {
          final req = p.isRequired ? 'required ' : '';
          return '$req${_displayType(p.type)} ${p.name}';
        })
        .join(', ');
    return '{$parts}';
  }

  /// Emits the `Map<String, dynamic>` literal passed to `transport.invoke`.
  String _buildArgsMap(MethodElement method) {
    if (method.parameters.isEmpty) return 'const {}';
    final entries = method.parameters
        .map((p) => "'${p.name}': ${p.name}")
        .join(', ');
    return '{$entries}';
  }

  /// Returns the inner type `T` of `Future<T>` with nullability stripped,
  /// suitable for use as the type argument in `transport.invoke<T>(...)`.
  String _futureInnerType(DartType type) {
    if (type is ParameterizedType && type.typeArguments.isNotEmpty) {
      return _stripNullability(type.typeArguments.first.toString());
    }
    return 'dynamic';
  }

  /// Returns the inner type `T` of `Stream<T>` with nullability stripped.
  String _streamInnerType(DartType type) {
    if (type is ParameterizedType && type.typeArguments.isNotEmpty) {
      return _stripNullability(type.typeArguments.first.toString());
    }
    return 'dynamic';
  }

  bool _isFuture(DartType type) =>
      type.isDartAsyncFuture || type.isDartAsyncFutureOr;

  bool _isStream(DartType type) => type.element?.name == 'Stream';

  /// Removes a trailing `?` from a type string to produce the non-nullable
  /// variant used as a generic type argument (e.g. `String?` → `String`).
  String _stripNullability(String typeStr) => typeStr.endsWith('?')
      ? typeStr.substring(0, typeStr.length - 1)
      : typeStr;

  /// Returns the display string for a [DartType] including nullability.
  /// Compatible with both analyzer ≤5 and ≥6 APIs.
  String _displayType(DartType type) {
    try {
      // analyzer ≤ 5.x: required named parameter
      // ignore: deprecated_member_use
      return (type as dynamic).getDisplayString(withNullability: true)
          as String;
    } catch (_) {
      // analyzer ≥ 6.x: no parameter
      return type.toString();
    }
  }
}
