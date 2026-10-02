/// Compares Dart contracts with native handler implementations
class DriftComparator {
  /// Compare Dart contract methods with native handler methods
  List<DriftIssue> compare({
    required List<String> contractMethods,
    required List<String> handlerMethods,
    required String platform,
  }) {
    final issues = <DriftIssue>[];

    // Normalize method names for comparison (convert to snake_case)
    final normalizedContractMethods =
        contractMethods.map(_toSnakeCase).toList();
    final normalizedHandlerMethods = handlerMethods.map(_toSnakeCase).toList();

    // Check for missing methods in handler
    for (final method in normalizedContractMethods) {
      if (!normalizedHandlerMethods.contains(method)) {
        issues.add(
          DriftIssue(
            type: 'missing_method',
            method: method,
            platform: platform,
            message: 'Method "$method" is missing in $platform handler',
          ),
        );
      }
    }

    // Check for extra methods in handler (not in contract)
    for (final method in normalizedHandlerMethods) {
      if (!normalizedContractMethods.contains(method)) {
        issues.add(
          DriftIssue(
            type: 'extra_method',
            method: method,
            platform: platform,
            message:
                'Method "$method" exists in $platform handler but not in contract',
          ),
        );
      }
    }

    return issues;
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
}

/// Represents a drift issue between contract and handler
class DriftIssue {
  final String type; // 'missing_method', 'extra_method', 'type_mismatch', etc.
  final String method;
  final String platform; // 'android' or 'ios'
  final String message;
  final String? details;

  DriftIssue({
    required this.type,
    required this.method,
    required this.platform,
    required this.message,
    this.details,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'method': method,
        'platform': platform,
        'message': message,
        'details': details,
      };

  @override
  String toString() => '$platform/$method: $message';
}
