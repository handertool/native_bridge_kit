import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:native_bridge_kit_annotation/native_bridge_kit_annotation.dart';

import 'kotlin_type_mapper.dart';

/// Generates Kotlin handler stubs for Android from Dart bridge contracts
class KotlinBridgeGenerator extends GeneratorForAnnotation<NativeBridge> {
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

    // Generate Kotlin code
    return _generateKotlinCode(className, channelName, methods);
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
        'kotlinType': dartTypeToKotlin(paramType),
      };
    }).toList();
  }

  /// Convert camelCase to snake_case
  String _toSnakeCase(String input) {
    final output = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      final char = input[i];
      if (i > 0 && char == char.toUpperCase() && char != char.toLowerCase()) {
        output.write('_');
      }
      output.write(char.toLowerCase());
    }
    return output.toString();
  }

  /// Get channel name from annotation or use class name
  String _getChannelName(ClassElement element, ConstantReader annotation) {
    final channelPrefix = annotation.read('channelPrefix');
    if (!channelPrefix.isNull) return channelPrefix.stringValue;
    // Default: use class name converted to snake_case
    return _toSnakeCase(element.name);
  }

  /// Generate complete Kotlin handler code
  String _generateKotlinCode(
    String className,
    String channelName,
    List<Map<String, dynamic>> methods,
  ) {
    final buffer = StringBuffer();

    buffer.writeln('// Generated by native_bridge_kit_android_gen');
    buffer.writeln('// Generated scaffold - implement the marked handlers.');
    buffer.writeln('');
    buffer.writeln('package com.example.pet_project.bridge');
    buffer.writeln('');
    buffer.writeln('import io.flutter.embedding.engine.FlutterEngine');
    buffer.writeln('import io.flutter.plugin.common.MethodCall');
    buffer.writeln('import io.flutter.plugin.common.MethodChannel');
    buffer.writeln('import io.flutter.plugin.common.EventChannel');
    buffer.writeln('');
    buffer.writeln('class ${className}Handler(');
    buffer.writeln('  private val flutterEngine: FlutterEngine');
    buffer.writeln(') {');
    buffer.writeln('  private val methodChannel = MethodChannel(');
    buffer.writeln('    flutterEngine.dartExecutor.binaryMessenger,');
    buffer.writeln('    "$channelName"');
    buffer.writeln('  )');
    buffer.writeln('');
    buffer.writeln('  fun setupChannelHandlers() {');
    buffer.writeln('    methodChannel.setMethodCallHandler { call, result ->');
    buffer.writeln('      try {');
    buffer.writeln('        when (call.method) {');

    for (final method in methods.where(
      (method) => !(method['isStream'] as bool),
    )) {
      final identifier = method['identifier'] as String;
      final wireName = method['wireName'] as String;
      buffer.writeln(
          '          "$wireName" -> handle${_capitalize(identifier)}(call, result)');
    }

    buffer.writeln('          else -> result.notImplemented()');
    buffer.writeln('        }');
    buffer.writeln('      } catch (e: Exception) {');
    buffer.writeln(
        '        result.error("ERROR", e.message ?: "Unknown error", null)');
    buffer.writeln('      }');
    buffer.writeln('    }');
    buffer.writeln('  }');
    buffer.writeln('');

    for (final method in methods.where(
      (method) => method['isStream'] as bool,
    )) {
      final identifier = method['identifier'] as String;
      final wireName = method['wireName'] as String;
      buffer.writeln('  private val ${identifier}EventChannel = EventChannel(');
      buffer.writeln('    flutterEngine.dartExecutor.binaryMessenger,');
      buffer.writeln('    "$channelName/$wireName"');
      buffer.writeln('  )');
      buffer.writeln('');
      buffer.writeln(
        '  private val ${identifier}StreamHandler = ${_capitalize(identifier)}StreamHandler()',
      );
      buffer.writeln('');
    }

    if (methods.any(
      (method) => method['isStream'] as bool,
    )) {
      buffer.writeln('  private fun registerEventChannels() {');
      for (final method in methods.where(
        (method) => method['isStream'] as bool,
      )) {
        final identifier = method['identifier'] as String;
        buffer.writeln(
          '    ${identifier}EventChannel.setStreamHandler(${identifier}StreamHandler)',
        );
      }
      buffer.writeln('  }');
      buffer.writeln('');
      buffer.writeln('  init {');
      buffer.writeln('    registerEventChannels()');
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
        buffer.writeln(_generateStreamHandlerStub(identifier, parameters));
      } else {
        buffer.writeln(
          _generateFutureHandlerStub(identifier, returnType, parameters),
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
  String _generateFutureHandlerStub(
    String kotlinMethodName,
    String returnType,
    List<Map<String, dynamic>> parameters,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('  private fun handle${_capitalize(kotlinMethodName)}(');
    buffer.writeln('    call: MethodCall,');
    buffer.writeln('    result: MethodChannel.Result');
    buffer.writeln('  ) {');
    buffer.writeln('    // BEGIN USER CODE - modify this method as needed');
    buffer.writeln('    try {');
    buffer.writeln(
        '      // TODO: Implement async handler for $kotlinMethodName');

    if (parameters.isNotEmpty) {
      buffer.writeln('      // Extract parameters:');
      for (final param in parameters) {
        final paramName = param['name'] as String;
        final paramType = param['type'] as String;
        buffer.writeln('      // - $paramName: $paramType');
      }
    }

    buffer.writeln(
        '      // For async work, you may want to use thread or coroutines');
    buffer.writeln('      val response: Any? = null // TODO: Implement');
    buffer.writeln('      result.success(response)');
    buffer.writeln('    } catch (e: Exception) {');
    buffer.writeln(
        '      result.error("${kotlinMethodName}_error", e.message, null)');
    buffer.writeln('    }');
    buffer.writeln('    // END USER CODE');
    buffer.writeln('  }');

    return buffer.toString();
  }

  /// Generate handler stub for Stream<T> event methods
  String _generateStreamHandlerStub(
    String kotlinMethodName,
    List<Map<String, dynamic>> parameters,
  ) {
    final buffer = StringBuffer()
      ..writeln(
        '  private inner class ${_capitalize(kotlinMethodName)}StreamHandler : EventChannel.StreamHandler {',
      )
      ..writeln('    override fun onListen(')
      ..writeln('      arguments: Any?,')
      ..writeln('      events: EventChannel.EventSink?')
      ..writeln('    ) {')
      ..writeln('      // BEGIN USER CODE - modify this method as needed')
      ..writeln(
        '      // TODO: Start listening to native events and emit via events?.success()',
      );

    if (parameters.isNotEmpty) {
      buffer.writeln('      // Stream arguments:');
      for (final param in parameters) {
        buffer.writeln('      // - ${param['name']}: ${param['type']}');
      }
    }

    buffer
      ..writeln('      // END USER CODE')
      ..writeln('    }')
      ..writeln()
      ..writeln('    override fun onCancel(arguments: Any?) {')
      ..writeln('      // TODO: Stop listening to native events')
      ..writeln('    }')
      ..writeln('  }');

    return buffer.toString();
  }
}
