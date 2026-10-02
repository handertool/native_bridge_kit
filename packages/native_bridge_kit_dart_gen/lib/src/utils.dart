/// Converts `UpperCamelCase` or `lowerCamelCase` identifiers to `snake_case`.
///
/// Examples:
/// * `DeviceInfoBridge` → `device_info_bridge`
/// * `getBatteryLevel`  → `get_battery_level`
/// * `getModel`         → `get_model`
String toSnakeCase(String input) {
  if (input.isEmpty) return input;
  return input
      // Insert underscore before each uppercase letter that is preceded by a
      // lowercase letter or digit (handles both camelCase and PascalCase).
      .replaceAllMapped(
        RegExp(r'(?<=[a-z0-9])([A-Z])'),
        (m) => '_${m.group(1)!.toLowerCase()}',
      )
      // Insert underscore between consecutive uppercase letters followed by a
      // lowercase letter (e.g. "XMLParser" → "xml_parser").
      .replaceAllMapped(
        RegExp(r'(?<=[A-Z])([A-Z][a-z])'),
        (m) => '_${m.group(1)!.toLowerCase()}',
      )
      .toLowerCase();
}
