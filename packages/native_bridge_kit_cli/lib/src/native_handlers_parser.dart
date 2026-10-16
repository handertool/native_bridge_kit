import 'dart:io';

import 'drift_comparator.dart';

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

    final dispatchPattern = RegExp(r'"([^"]+)"\s*->');
    for (final match in dispatchPattern.allMatches(content)) {
      _addMethod(methods, match.group(1)!, 'method');
    }

    final eventChannelPattern = RegExp(
      r'EventChannel\s*\(([\s\S]*?)\)',
      multiLine: true,
    );
    for (final match in eventChannelPattern.allMatches(content)) {
      final arguments = match.group(1)!;
      final channelName = RegExp(r'"([^"]+)"').firstMatch(arguments)?.group(1);
      final slash = channelName?.lastIndexOf('/') ?? -1;
      if (channelName != null && slash >= 0) {
        _addMethod(methods, channelName.substring(slash + 1), 'stream');
      }
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

    final dispatchPattern = RegExp(r'case\s+"([^"]+)"\s*:');
    for (final match in dispatchPattern.allMatches(content)) {
      _addMethod(methods, match.group(1)!, 'method');
    }

    final eventChannelPattern = RegExp(
      r'FlutterEventChannel\s*\(([\s\S]*?)\)',
      multiLine: true,
    );
    for (final match in eventChannelPattern.allMatches(content)) {
      final arguments = match.group(1)!;
      final channelName = RegExp(r'"([^"]+)"').firstMatch(arguments)?.group(1);
      final slash = channelName?.lastIndexOf('/') ?? -1;
      if (channelName != null && slash >= 0) {
        _addMethod(methods, channelName.substring(slash + 1), 'stream');
      }
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
}

/// Handler metadata
class HandlerMetadata {
  final String file;
  final List<BridgeOperation> operations;

  HandlerMetadata({
    required this.file,
    required this.operations,
  });

  factory HandlerMetadata.fromMap(Map<String, dynamic> data) {
    final operations = (data['methods'] as List).map((method) {
      final values = method as Map;
      return BridgeOperation(
        name: values['name'] as String,
        kind: values['type'] as String,
      );
    }).toList();
    return HandlerMetadata(
      file: data['file'] as String,
      operations: operations,
    );
  }
}
