import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:native_bridge_kit_annotation/native_bridge_kit_annotation.dart';

import 'swift_type_mapper.dart';

/// Generates Swift handler stubs for iOS from Dart bridge contracts
class SwiftBridgeGenerator extends GeneratorForAnnotation<NativeBridge> {
  static const _nativeMethodChecker = TypeChecker.fromRuntime(NativeMethod);
  static const _nativeStreamChecker = TypeChecker.fromRuntime(NativeStream);

  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '@NativeBridge can only be applied to classes',
        element: element,
      );
    }

    final className = element.name;
    final channelName = _getChannelName(element, annotation);

    // Extract methods from the class
    final methods = _extractMethods(element);

    // Generate Swift code
    return _generateSwiftCode(className, channelName, methods);
  }

  /// Extract method information from Dart contract
  List<Map<String, dynamic>> _extractMethods(ClassElement classElement) {
    final methods = <Map<String, dynamic>>[];

    for (final method in classElement.methods) {
      // Skip private methods and constructors
      if (method.isPrivate || method.isStatic) {
        continue;
      }

      final methodName = method.name;
      final returnType = method.returnType;
      final isStream = returnType.element?.name == 'Stream';
      final isFuture = returnType.isDartAsyncFuture;
      if (!isStream && !isFuture) {
        throw InvalidGenerationSourceError(
          'Method "$methodName" has unsupported return type "$returnType". '
          'Use Future<T> for one-shot calls or Stream<T> for event streams.',
          element: method,
        );
      }
      if (isStream && method.parameters.isNotEmpty) {
        throw InvalidGenerationSourceError(
          'Stream method "$methodName" declares parameters. '
          'Stream arguments are not supported by native_bridge_kit.',
          element: method,
        );
      }

      final positional = method.parameters.where((p) => !p.isNamed).toList();
      if (positional.isNotEmpty) {
        throw InvalidGenerationSourceError(
          'Method "$methodName" has positional parameters '
          '(${positional.map((p) => p.name).join(', ')}). '
          'Only named parameters are supported by native_bridge_kit.',
          element: method,
        );
      }

      final parameters = _extractParameters(method);
      final wireName = _resolveWireName(method);

      methods.add({
        'name': methodName,
        'dartName': methodName,
        'identifier': _toSnakeCase(methodName),
        'wireName': wireName,
        'parameters': parameters,
        'isStream': isStream,
        'returnType': returnType.toString(),
      });
    }
    return methods;
  }

  String _resolveWireName(MethodElement method) {
    final methodAnnotation =
        _nativeMethodChecker.firstAnnotationOfExact(method);
    if (methodAnnotation != null) {
      final name = ConstantReader(methodAnnotation).read('name');
      if (!name.isNull) return name.stringValue;
    }

    final streamAnnotation =
        _nativeStreamChecker.firstAnnotationOfExact(method);
    if (streamAnnotation != null) {
      final name = ConstantReader(streamAnnotation).read('name');
      if (!name.isNull) return name.stringValue;
    }

    return _toSnakeCase(method.name);
  }

  /// Extract parameter information from method
  List<Map<String, dynamic>> _extractParameters(MethodElement method) {
    return method.parameters.map((param) {
      final paramType = param.type.toString();
      return {
        'name': param.name,
        'type': paramType,
        'isRequired': param.isRequired,
        'swiftType': dartTypeToSwift(paramType),
      };
    }).toList();
  }

  /// Get channel name from annotation or use class name
  String _getChannelName(ClassElement element, ConstantReader annotation) {
    final channelPrefix = annotation.read('channelPrefix');
    if (!channelPrefix.isNull) return channelPrefix.stringValue;
    // Default: use class name converted to snake_case
    return _toSnakeCase(element.name);
  }

  /// Convert camelCase/PascalCase to snake_case wire names.
  String _toSnakeCase(String input) {
    final output = StringBuffer();
    for (var i = 0; i < input.length; i++) {
      final char = input[i];
      if (i > 0 && char == char.toUpperCase() && char != char.toLowerCase()) {
        output.write('_');
      }
      output.write(char.toLowerCase());
    }
    return output.toString();
  }

  /// Generate complete Swift handler code
  String _generateSwiftCode(
    String className,
    String channelName,
    List<Map<String, dynamic>> methods,
  ) {
    final buffer = StringBuffer();

    buffer.writeln('// Generated by native_bridge_kit_ios_gen');
    buffer.writeln('// Generated scaffold - implement the marked handlers.');
    buffer.writeln('');
    buffer.writeln('import Flutter');
    buffer.writeln('');
    buffer.writeln('class ${className}Handler {');
    buffer.writeln('  private let methodChannel: FlutterMethodChannel');
    buffer.writeln('');
    buffer.writeln('  init(controller: FlutterViewController) {');
    buffer.writeln('    self.methodChannel = FlutterMethodChannel(');
    buffer.writeln('      name: "$channelName",');
    buffer.writeln('      binaryMessenger: controller.binaryMessenger');
    buffer.writeln('    )');
    for (final method in methods.where(
      (method) => method['isStream'] as bool,
    )) {
      final identifier = method['identifier'] as String;
      final wireName = method['wireName'] as String;
      buffer.writeln(
        '    self.${identifier}EventChannel = FlutterEventChannel(',
      );
      buffer.writeln(
        '      name: "$channelName/$wireName",',
      );
      buffer.writeln('      binaryMessenger: controller.binaryMessenger');
      buffer.writeln('    )');
    }
    buffer.writeln('  }');
    buffer.writeln('');
    buffer.writeln('  func setupChannelHandlers() {');
    buffer
        .writeln('    methodChannel.setMethodCallHandler { (call, result) in');
    buffer.writeln('      switch call.method {');

    for (final method in methods.where(
      (method) => !(method['isStream'] as bool),
    )) {
      final identifier = method['identifier'] as String;
      final wireName = method['wireName'] as String;
      buffer.writeln('        case "$wireName":');
      buffer.writeln(
          '          self.handle${_capitalize(identifier)}(call, result: result)');
    }

    buffer.writeln('        default:');
    buffer.writeln('          result(FlutterMethodNotImplemented)');
    buffer.writeln('        }');
    buffer.writeln('    }');
    for (final method in methods.where(
      (method) => method['isStream'] as bool,
    )) {
      final identifier = method['identifier'] as String;
      buffer.writeln(
        '    register${_capitalize(identifier)}EventChannel()',
      );
    }
    buffer.writeln('  }');
    buffer.writeln('');

    for (final method in methods.where(
      (method) => method['isStream'] as bool,
    )) {
      final identifier = method['identifier'] as String;
      buffer.writeln(
          '  private let ${identifier}EventChannel: FlutterEventChannel');
      buffer.writeln('');
      buffer.writeln(
        '  private func register${_capitalize(identifier)}EventChannel() {',
      );
      buffer.writeln(
        '    ${identifier}EventChannel.setStreamHandler(${_capitalize(identifier)}StreamHandler())',
      );
      buffer.writeln('  }');
      buffer.writeln('');
    }

    // Generate method stubs
    for (final method in methods) {
      final identifier = method['identifier'] as String;
      final returnType = method['returnType'] as String;
      final parameters = method['parameters'] as List<Map<String, dynamic>>;
      final isStream = method['isStream'] as bool;

      if (isStream) {
        buffer.writeln(_generateSwiftStreamHandlerStub(identifier, parameters));
      } else {
        buffer.writeln(
          _generateSwiftFutureHandlerStub(identifier, returnType, parameters),
        );
      }
      buffer.writeln('');
    }

    buffer.writeln('}');

    return buffer.toString();
  }

  /// Capitalize first letter
  String _capitalize(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }

  /// Generate handler stub for Future<T> async methods
  String _generateSwiftFutureHandlerStub(
    String swiftMethodName,
    String returnType,
    List<Map<String, dynamic>> parameters,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('  private func handle${_capitalize(swiftMethodName)}(');
    buffer.writeln('    _ call: FlutterMethodCall,');
    buffer.writeln('    result: @escaping FlutterResult');
    buffer.writeln('  ) {');
    buffer.writeln(
        '    // MARK: - BEGIN USER CODE - modify this method as needed');
    buffer.writeln('    // TODO: Implement async handler for $swiftMethodName');

    if (parameters.isNotEmpty) {
      buffer.writeln('    // Extract parameters:');
      for (final param in parameters) {
        final paramName = param['name'] as String;
        final paramType = param['type'] as String;
        buffer.writeln('    // - $paramName: $paramType');
      }
    }

    buffer.writeln('    // For async work, use DispatchQueue or async/await');
    buffer.writeln('    let response: Any? = nil // TODO: Implement');
    buffer.writeln('    result(response)');
    buffer.writeln('    // MARK: - END USER CODE');
    buffer.writeln('  }');

    return buffer.toString();
  }

  /// Generate handler stub for Stream<T> event methods
  String _generateSwiftStreamHandlerStub(
    String swiftMethodName,
    List<Map<String, dynamic>> parameters,
  ) {
    final buffer = StringBuffer()
      ..writeln(
        '  private final class ${_capitalize(swiftMethodName)}StreamHandler: NSObject, FlutterStreamHandler {',
      )
      ..writeln('    private var eventSink: FlutterEventSink?')
      ..writeln()
      ..writeln(
        '    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {',
      )
      ..writeln(
        '      // MARK: - BEGIN USER CODE - start native events and call eventSink',
      )
      ..writeln('      self.eventSink = events');

    if (parameters.isNotEmpty) {
      buffer.writeln('      // Stream arguments:');
      for (final param in parameters) {
        buffer.writeln('      // - ${param['name']}: ${param['type']}');
      }
    }

    buffer
      ..writeln('      // MARK: - END USER CODE')
      ..writeln('      return nil')
      ..writeln('    }')
      ..writeln()
      ..writeln(
        '    func onCancel(withArguments arguments: Any?) -> FlutterError? {',
      )
      ..writeln('      self.eventSink = nil')
      ..writeln('      // TODO: Stop listening to native events')
      ..writeln('      return nil')
      ..writeln('    }')
      ..writeln('  }');

    return buffer.toString();
  }
}
