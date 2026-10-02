import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/session.dart';

/// Parses Dart contract files and extracts bridge metadata
class DartContractParser {
  final String contractPath;
  late final AnalysisSession analysisSession;

  DartContractParser(this.contractPath);

  /// Initialize the analysis session
  Future<void> initialize() async {
    final resourceProvider = PhysicalResourceProvider.INSTANCE;
    final contextCollection = AnalysisContextCollection(
      includedPaths: [contractPath],
      resourceProvider: resourceProvider,
    );
    analysisSession = contextCollection.contexts.first.currentSession;
  }

  /// Parse contract file and extract all bridge methods
  Future<Map<String, dynamic>> parseContract() async {
    await initialize();

    final parseResult = await analysisSession.getResolvedUnit(contractPath);
    if (parseResult is! ResolvedUnitResult) {
      throw Exception('Failed to parse contract: $contractPath');
    }

    final contractData = <String, dynamic>{
      'file': contractPath,
      'methods': <Map<String, dynamic>>[],
    };

    // Find classes with @NativeBridge annotation
    for (final element in parseResult.unit.declarations) {
      if (element is ClassDeclaration) {
        // Check for @NativeBridge annotation
        bool hasNativeBridge = false;
        for (final metadata in element.metadata) {
          if (metadata.name.name == 'NativeBridge') {
            hasNativeBridge = true;
            break;
          }
        }

        if (hasNativeBridge) {
          final methods = _extractMethods(element);
          (contractData['methods'] as List).addAll(methods);
        }
      }
    }

    return contractData;
  }

  /// Extract methods from a class element
  List<Map<String, dynamic>> _extractMethods(ClassDeclaration classDecl) {
    final methods = <Map<String, dynamic>>[];

    for (final member in classDecl.members) {
      if (member is MethodDeclaration && !member.name.lexeme.startsWith('_')) {
        final methodName = member.name.lexeme;
        final returnType = member.returnType?.toString() ?? 'void';
        final parameters = _extractParameters(member);

        methods.add({
          'name': methodName,
          'returnType': returnType,
          'parameters': parameters,
        });
      }
    }

    return methods;
  }

  /// Extract parameters from method
  List<Map<String, dynamic>> _extractParameters(MethodDeclaration method) {
    final parameters = method.parameters?.parameters ?? const [];
    return parameters.map((param) {
      return <String, dynamic>{
        'name': param.name?.lexeme ?? '',
        'type': param.declaredElement?.type.toString() ?? 'dynamic',
        'isRequired': param.isRequired,
      };
    }).toList();
  }
}

/// Contract metadata
class ContractMetadata {
  final String file;
  final List<MethodMetadata> methods;

  ContractMetadata({
    required this.file,
    required this.methods,
  });

  factory ContractMetadata.fromMap(Map<String, dynamic> data) {
    final methods = (data['methods'] as List)
        .cast<Map<String, dynamic>>()
        .map((m) => MethodMetadata.fromMap(m))
        .toList();
    return ContractMetadata(
      file: data['file'] as String,
      methods: methods,
    );
  }
}

/// Method metadata
class MethodMetadata {
  final String name;
  final String returnType;
  final List<ParameterMetadata> parameters;

  MethodMetadata({
    required this.name,
    required this.returnType,
    required this.parameters,
  });

  factory MethodMetadata.fromMap(Map<String, dynamic> data) {
    final parameters = (data['parameters'] as List)
        .cast<Map<String, dynamic>>()
        .map((p) => ParameterMetadata.fromMap(p))
        .toList();
    return MethodMetadata(
      name: data['name'] as String,
      returnType: data['returnType'] as String,
      parameters: parameters,
    );
  }
}

/// Parameter metadata
class ParameterMetadata {
  final String name;
  final String type;
  final bool isRequired;

  ParameterMetadata({
    required this.name,
    required this.type,
    required this.isRequired,
  });

  factory ParameterMetadata.fromMap(Map<String, dynamic> data) {
    return ParameterMetadata(
      name: data['name'] as String,
      type: data['type'] as String,
      isRequired: data['isRequired'] as bool? ?? false,
    );
  }
}
