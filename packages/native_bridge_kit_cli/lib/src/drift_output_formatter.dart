import 'dart:convert';
import 'drift_comparator.dart';

/// Formats drift check results for output
class DriftOutputFormatter {
  /// Format issues as human-readable output
  static String formatHuman(
    List<DriftIssue> issues, {
    bool colorize = true,
  }) {
    if (issues.isEmpty) {
      return '✓ Contract and stubs are in sync';
    }

    final buffer = StringBuffer();
    buffer.writeln('✗ Found ${issues.length} drift issue(s):\n');

    final issuesByPlatform = <String, List<DriftIssue>>{};
    for (final issue in issues) {
      issuesByPlatform.putIfAbsent(issue.platform, () => []).add(issue);
    }

    for (final platform in ['android', 'ios']) {
      final platformIssues = issuesByPlatform[platform] ?? [];
      if (platformIssues.isNotEmpty) {
        buffer.writeln('  $platform:');
        for (final issue in platformIssues) {
          buffer.writeln('    • ${issue.message}');
          if (issue.details != null) {
            buffer.writeln('      ${issue.details}');
          }
        }
        buffer.writeln('');
      }
    }

    buffer.writeln(
        'Remediation: Run `build_runner build` to regenerate handlers');
    return buffer.toString();
  }

  /// Format issues as JSON output
  static String formatJson(
    List<DriftIssue> issues, {
    required bool inSync,
  }) {
    final data = {
      'in_sync': inSync,
      'issue_count': issues.length,
      'issues': issues.map((issue) => issue.toJson()).toList(),
    };
    return jsonEncode(data);
  }
}
