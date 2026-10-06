/// Maps Dart contract types to Kotlin types used by generated handlers.
String dartTypeToKotlin(String dartType) {
  final type = dartType.trim();
  final nullable = type.endsWith('?');
  final nonNullable = nullable ? type.substring(0, type.length - 1) : type;
  final mapped = _mapNonNullableType(nonNullable);
  return nullable && mapped != 'Any?' && mapped != 'Void' ? '$mapped?' : mapped;
}

String _mapNonNullableType(String type) {
  const primitiveTypes = {
    'String': 'String',
    'int': 'Int',
    'double': 'Double',
    'bool': 'Boolean',
    'Null': 'Void',
  };

  final primitive = primitiveTypes[type];
  if (primitive != null) return primitive;

  final futureInner = _genericArgument(type, 'Future');
  if (futureInner != null) return dartTypeToKotlin(futureInner);
  if (_genericArgument(type, 'Stream') != null) return 'Any';

  final listInner = _genericArgument(type, 'List');
  if (listInner != null) return 'List<${dartTypeToKotlin(listInner)}>';

  final mapArguments = _genericArguments(type, 'Map');
  if (mapArguments != null && mapArguments.length == 2) {
    return 'Map<${dartTypeToKotlin(mapArguments[0])}, '
        '${dartTypeToKotlin(mapArguments[1])}>';
  }

  return 'Any';
}

String? _genericArgument(String type, String name) {
  final arguments = _genericArguments(type, name);
  if (arguments == null || arguments.length != 1) return null;
  return arguments.single;
}

List<String>? _genericArguments(String type, String name) {
  final prefix = '$name<';
  if (!type.startsWith(prefix) || !type.endsWith('>')) return null;
  final content = type.substring(prefix.length, type.length - 1);
  final arguments = <String>[];
  var depth = 0;
  var start = 0;
  for (var i = 0; i < content.length; i++) {
    final character = content[i];
    if (character == '<') depth++;
    if (character == '>') depth--;
    if (character == ',' && depth == 0) {
      arguments.add(content.substring(start, i).trim());
      start = i + 1;
    }
  }
  arguments.add(content.substring(start).trim());
  return arguments;
}
