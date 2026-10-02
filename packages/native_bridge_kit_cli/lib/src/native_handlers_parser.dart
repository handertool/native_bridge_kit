import 'dart:io';

/// Parses Kotlin source files and extracts bridge handler metadata
class KotlinHandlerParser {
  final String handlerPath;

  KotlinHandlerParser(this.handlerPath);

  /// Parse Kotlin source and extract handler method metadata
  Map<String, dynamic> parseHandler() {
    final file = File(handlerPath);
    if (!file.existsSync()) {
      throw Exception('Kotlin handler not found: $handlerPath');
    }

    final content = file.readAsStringSync();
    final methods = _extractMethods(content);

    return {
      'file': handlerPath,
      'methods': methods,
    };
  }

  /// Extract method information from Kotlin source
  List<Map<String, dynamic>> _extractMethods(String content) {
    final methods = <Map<String, dynamic>>[];

    // Simple regex-based extraction for method signatures
    // Pattern: private fun handleGet<MethodName>(call: MethodCall, result: MethodChannel.Result)
    final methodPattern = RegExp(
      r'private fun handleGet(\w+)\s*\(',
      multiLine: true,
    );

    for (final match in methodPattern.allMatches(content)) {
      final methodNameCamel = match.group(1) ?? '';
      // Convert from handleGetXxx to xxx (snake_case will be added back)
      methods.add({
        'name': _camelToSnakeCase(methodNameCamel),
        'type': 'method',
      });
    }

    final dispatchPattern = RegExp(r'"([a-z][a-zA-Z0-9_]*)"\s*->');
    for (final match in dispatchPattern.allMatches(content)) {
      _addMethod(methods, match.group(1)!, 'method');
    }

    final streamPattern = RegExp(r'"\$CHANNEL/([a-z][a-zA-Z0-9_]*)"');
    for (final match in streamPattern.allMatches(content)) {
      _addMethod(methods, match.group(1)!, 'stream');
    }

    return methods;
  }

  void _addMethod(
    List<Map<String, dynamic>> methods,
    String name,
    String type,
  ) {
    if (!methods.any((method) => method['name'] == name)) {
      methods.add({'name': name, 'type': type});
    }
  }

  /// Convert camelCase to snake_case
  String _camelToSnakeCase(String input) {
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
}

/// Parses Swift source files and extracts bridge handler metadata
class SwiftHandlerParser {
  final String handlerPath;

  SwiftHandlerParser(this.handlerPath);

  /// Parse Swift source and extract handler method metadata
  Map<String, dynamic> parseHandler() {
    final file = File(handlerPath);
    if (!file.existsSync()) {
      throw Exception('Swift handler not found: $handlerPath');
    }

    final content = file.readAsStringSync();
    final methods = _extractMethods(content);

    return {
      'file': handlerPath,
      'methods': methods,
    };
  }

  /// Extract method information from Swift source
  List<Map<String, dynamic>> _extractMethods(String content) {
    final methods = <Map<String, dynamic>>[];

    // Simple regex-based extraction for method signatures
    // Pattern: private func handle<MethodName>(
    final methodPattern = RegExp(
      r'private func handle(\w+)\s*\(',
      multiLine: true,
    );

    for (final match in methodPattern.allMatches(content)) {
      final methodNameCamel = match.group(1) ?? '';
      // Keep camelCase for Swift methods
      methods.add({
        'name': _camelCaseToSnakeCase(methodNameCamel),
        'type': 'method',
      });
    }

    final dispatchPattern = RegExp(r'case\s+"([a-z][a-zA-Z0-9_]*)"\s*:');
    for (final match in dispatchPattern.allMatches(content)) {
      _addMethod(methods, match.group(1)!, 'method');
    }

    final streamPattern = RegExp(
      r'name:\s*"[a-z][a-zA-Z0-9_]*/([a-z][a-zA-Z0-9_]*)"',
    );
    for (final match in streamPattern.allMatches(content)) {
      _addMethod(methods, match.group(1)!, 'stream');
    }

    return methods;
  }

  void _addMethod(
    List<Map<String, dynamic>> methods,
    String name,
    String type,
  ) {
    if (!methods.any((method) => method['name'] == name)) {
      methods.add({'name': name, 'type': type});
    }
  }

  /// Convert camelCase to snake_case for comparison
  String _camelCaseToSnakeCase(String input) {
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
}

/// Handler metadata
class HandlerMetadata {
  final String file;
  final List<String> methods;

  HandlerMetadata({
    required this.file,
    required this.methods,
  });

  factory HandlerMetadata.fromMap(Map<String, dynamic> data) {
    final methods = ((data['methods'] as List)
        .map((m) => (m as Map)['name'] as String)
        .toList());
    return HandlerMetadata(
      file: data['file'] as String,
      methods: methods,
    );
  }
}
