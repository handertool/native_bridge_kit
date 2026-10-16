/// A method call or event stream exposed by a bridge.
class BridgeOperation {
  const BridgeOperation({
    required this.name,
    required this.kind,
  });

  /// Exact wire-level operation name.
  final String name;

  /// Either `method` or `stream`.
  final String kind;
}

/// Compares Dart contracts with native handler implementations.
class DriftComparator {
  /// Compare resolved contract operations with native handler operations.
  List<DriftIssue> compare({
    required List<BridgeOperation> contractOperations,
    required List<BridgeOperation> handlerOperations,
    required String platform,
  }) {
    final issues = <DriftIssue>[];

    for (final contractOperation in contractOperations) {
      final handlerOperation = _findByName(
        handlerOperations,
        contractOperation.name,
      );
      if (handlerOperation == null) {
        issues.add(
          DriftIssue(
            type: 'missing_operation',
            method: contractOperation.name,
            platform: platform,
            message: '${_displayKind(contractOperation.kind)} '
                '"${contractOperation.name}" is missing in $platform handler',
          ),
        );
      } else if (handlerOperation.kind != contractOperation.kind) {
        issues.add(
          DriftIssue(
            type: 'operation_kind_mismatch',
            method: contractOperation.name,
            platform: platform,
            message: 'Operation "${contractOperation.name}" is a '
                '${contractOperation.kind} in the Dart contract but a '
                '${handlerOperation.kind} in the $platform handler',
          ),
        );
      }
    }

    for (final handlerOperation in handlerOperations) {
      if (_findByName(contractOperations, handlerOperation.name) == null) {
        issues.add(
          DriftIssue(
            type: 'extra_operation',
            method: handlerOperation.name,
            platform: platform,
            message: '${_displayKind(handlerOperation.kind)} '
                '"${handlerOperation.name}" exists in $platform handler '
                'but not in the contract',
          ),
        );
      }
    }

    return issues;
  }

  BridgeOperation? _findByName(List<BridgeOperation> operations, String name) {
    for (final operation in operations) {
      if (operation.name == name) return operation;
    }
    return null;
  }

  String _displayKind(String kind) => kind == 'stream' ? 'Stream' : 'Method';
}

/// Represents a drift issue between a Dart contract and a native handler.
class DriftIssue {
  final String type;
  final String method;
  final String platform;
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
