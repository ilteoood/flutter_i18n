import 'dart:io';

import 'package:path/path.dart' as p;

/// A reference to a translation key found in source code.
class DynamicKeyRef {
  final String filePath;
  final int line;
  final String lineContent;

  const DynamicKeyRef(this.filePath, this.line, this.lineContent);
}

/// Configuration extracted from a NamespaceFileTranslationLoader constructor
/// in source code.
class NamespaceConfig {
  final String? basePath;
  final List<String> namespaces;

  const NamespaceConfig({this.basePath, this.namespaces = const []});

  bool get isNamespace => namespaces.isNotEmpty;
}

/// Result of scanning source files for translation key usages.
class SourceScanResult {
  final Set<String> literalKeys;
  final List<DynamicKeyRef> dynamicRefs;
  final List<NamespaceConfig> namespaceConfigs;

  const SourceScanResult(
    this.literalKeys,
    this.dynamicRefs, {
    this.namespaceConfigs = const [],
  });
}

/// Scans Dart source files for FlutterI18n key usages using regex.
///
/// Recognizes four call patterns (with optional import-alias prefix):
/// - `FlutterI18n.translate(context, "key")`
/// - `FlutterI18n.plural(context, "key", n)`
/// - `I18nText("key")`
/// - `I18nPlural("key", n)`
///
/// Also captures keys from `fallbackKey:` named parameters.
class SourceScanner {
  // Matches fallbackKey: "..." or fallbackKey: '...'
  static final _fallbackKeyRe = RegExp(
    r"""fallbackKey\s*:\s*["']([^"']*)["']""",
  );

  // Matches any FlutterI18n.translate/plural or I18nText/I18nPlural call
  // site — the opening `(` is included so we can locate the argument list.
  static final _dynamicCallRe = RegExp(
    r"""(?:\w+\.)?\b(?:FlutterI18n\s*\.\s*(?:translate|plural)|I18n(?:Text|Plural))\s*\(""",
  );

  // Extracts hardcoded string literals from call arguments — useful for
  // ternary branches like `cond ? "key.a" : "key.b"`.
  static final _stringLiteralRe = RegExp(r"""["']([^"']+)["']""");

  /// Scans all `.dart` files under [projectRoot] and returns extracted keys
  /// plus any dynamic references.
  ///
  /// If [scanPaths] is provided, only those files/directories are scanned
  /// (relative to [projectRoot] unless absolute). Defaults to `lib/` and
  /// `test/` directories.
  static SourceScanResult scan(String projectRoot, {List<String>? scanPaths}) {
    final literalKeys = <String>{};
    final dynamicRefs = <DynamicKeyRef>[];
    final namespaceConfigs = <NamespaceConfig>[];

    final dartFiles = _findDartFiles(projectRoot, scanPaths: scanPaths);
    for (final file in dartFiles) {
      _scanFile(file, literalKeys, dynamicRefs);
      _scanNamespaceConfigs(file, namespaceConfigs);
    }

    return SourceScanResult(literalKeys, dynamicRefs,
        namespaceConfigs: namespaceConfigs);
  }

  static List<File> _findDartFiles(String root, {List<String>? scanPaths}) {
    final rootDir = Directory(root);
    if (!rootDir.existsSync()) return [];

    final targetPaths = (scanPaths != null && scanPaths.isNotEmpty)
        ? scanPaths
        : ['lib', 'test'];

    final files = <File>[];
    for (final scanPath in targetPaths) {
      final fullPath =
          p.isAbsolute(scanPath) ? scanPath : p.join(root, scanPath);
      final type = FileSystemEntity.typeSync(fullPath, followLinks: false);
      if (type == FileSystemEntityType.file && fullPath.endsWith('.dart')) {
        files.add(File(fullPath));
      } else if (type == FileSystemEntityType.directory) {
        _collectDartFiles(Directory(fullPath), files);
      }
    }

    return files;
  }

  static void _collectDartFiles(Directory dir, List<File> files) {
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        files.add(entity);
      }
    }
  }

  static void _scanFile(
    File file,
    Set<String> literalKeys,
    List<DynamicKeyRef> dynamicRefs,
  ) {
    final lines = file.readAsLinesSync();
    final strippedLines = lines.map((line) {
      final idx = _findCommentIndex(line);
      return idx >= 0 ? line.substring(0, idx) : line;
    }).toList();
    final stripped = strippedLines.join('\n');

    // fallbackKey references can appear anywhere in a call.
    for (final match in _fallbackKeyRe.allMatches(stripped)) {
      final key = match.group(1)!;
      if (!key.contains(r'$')) literalKeys.add(key);
    }

    // Classify each FlutterI18n / I18nText / I18nPlural call site.
    for (final match in _dynamicCallRe.allMatches(stripped)) {
      // match.end points right after the opening '('.
      final openParen = match.end - 1;
      final closeParen = _findMatchingParen(stripped, openParen);
      if (closeParen == -1) continue;

      // Fluent API → key is 2nd positional arg (index 1).
      // Widget constructors → key is 1st positional arg (index 0).
      final isFluent = match.group(0)!.contains('FlutterI18n');
      final argIndex = isFluent ? 1 : 0;

      final keyArg = _extractArg(stripped, match.end, argIndex);
      if (keyArg == null) continue;

      if (_isPureString(keyArg)) {
        final inner = keyArg.trim();
        final value = inner.substring(1, inner.length - 1);
        if (!value.contains(r'$')) {
          literalKeys.add(value);
          continue;
        }
      }

      // Key argument is not a plain string — extract any hardcoded string
      // literals inside it (e.g. ternary branches) for the literal set,
      // and also flag the call as dynamic.
      for (final m in _stringLiteralRe.allMatches(keyArg)) {
        final s = m.group(1)!;
        if (!s.contains(r'$')) literalKeys.add(s);
      }
      final lineNum = _offsetToLine(strippedLines, match.start);
      final fullCall = stripped.substring(match.start, closeParen + 1);
      dynamicRefs.add(DynamicKeyRef(file.path, lineNum, fullCall));
    }
  }

  /// True when [arg] is a single string literal (possibly surrounded by
  /// whitespace), e.g. `"home.title"` or `  'settings.general'  `.
  static bool _isPureString(String arg) {
    final t = arg.trim();
    return (t.startsWith('"') && t.endsWith('"') && t.length >= 2) ||
        (t.startsWith("'") && t.endsWith("'") && t.length >= 2);
  }

  /// Extracts the [argIndex]-th positional argument (0-based) from the
  /// argument list starting at [start] in [content].  Tracks nested
  /// parentheses and string literals so that commas inside them are not
  /// treated as argument separators.
  static String? _extractArg(String content, int start, int argIndex) {
    var depth = 0;
    var inSingle = false;
    var inDouble = false;
    var argStart = start;
    var currentArg = 0;

    for (var i = start; i < content.length; i++) {
      final ch = content[i];
      if (ch == "'" && !inDouble) {
        inSingle = !inSingle;
      } else if (ch == '"' && !inSingle) {
        inDouble = !inDouble;
      } else if (!inSingle && !inDouble) {
        if (ch == '(') {
          depth++;
        } else if (ch == ')') {
          if (depth == 0) {
            // End of call — return the current arg if it is the target.
            if (currentArg == argIndex) {
              return content.substring(argStart, i);
            }
            return null;
          }
          depth--;
        } else if (ch == ',' && depth == 0) {
          if (currentArg == argIndex) {
            return content.substring(argStart, i);
          }
          currentArg++;
          argStart = i + 1;
        }
      }
    }
    return null;
  }

  /// Converts a character offset in joined [lines] (separated by '\n') to a
  /// 1-based line number.
  static int _offsetToLine(List<String> lines, int offset) {
    var current = 0;
    for (var i = 0; i < lines.length; i++) {
      current += lines[i].length + 1; // +1 for '\n'
      if (current > offset) return i + 1;
    }
    return lines.length;
  }

  /// Returns the index of the first `//` that is _not_ inside a string literal,
  /// or -1 if there is no comment on this line.
  ///
  /// Handles both single- and double-quoted strings. Does not handle
  /// multi-line strings or escaped quotes inside strings.
  static int _findCommentIndex(String line) {
    var inSingle = false;
    var inDouble = false;

    for (var i = 0; i < line.length - 1; i++) {
      final ch = line[i];
      if (ch == "'" && !inDouble) {
        inSingle = !inSingle;
      } else if (ch == '"' && !inSingle) {
        inDouble = !inDouble;
      } else if (ch == '/' && !inSingle && !inDouble) {
        if (line[i + 1] == '/') return i;
      }
    }
    return -1;
  }

  // Matches NamespaceFileTranslationLoader constructor with optional alias.
  static final _nsLoaderRe = RegExp(
    r'(?:\w+\.)?\bNamespaceFileTranslationLoader\s*\(',
  );

  /// Scans [file] for NamespaceFileTranslationLoader constructors and
  /// extracts namespace configuration.
  static void _scanNamespaceConfigs(
      File file, List<NamespaceConfig> results) {
    final content = file.readAsStringSync();

    for (final match in _nsLoaderRe.allMatches(content)) {
      final closeParen = _findMatchingParen(content, match.end - 1);
      if (closeParen == -1) continue;

      final region = content.substring(match.start, closeParen + 1);

      final nsMatch =
          RegExp(r'''namespaces\s*:\s*\[([^\]]*)\]''').firstMatch(region);
      if (nsMatch == null) continue;

      final namespaces = _parseStringList(nsMatch.group(1)!);
      if (namespaces.isEmpty) continue;

      final bpMatch =
          RegExp(r'''basePath\s*:\s*['"]([^'"]*)['"]''').firstMatch(region);
      final basePath = bpMatch?.group(1);

      results.add(NamespaceConfig(
        basePath: basePath,
        namespaces: namespaces,
      ));
    }
  }

  /// Finds the matching `)` for the opening paren at [openPos], accounting
  /// for string literals.
  static int _findMatchingParen(String content, int openPos) {
    var depth = 0;
    var inSingle = false;
    var inDouble = false;

    for (var i = openPos; i < content.length; i++) {
      final ch = content[i];
      if (ch == "'" && !inDouble) {
        inSingle = !inSingle;
      } else if (ch == '"' && !inSingle) {
        inDouble = !inDouble;
      } else if (!inSingle && !inDouble) {
        if (ch == '(') depth++;
        if (ch == ')') {
          depth--;
          if (depth == 0) return i;
        }
      }
    }
    return -1;
  }

  /// Parses `"common", "home"` or `'common', 'home'` into a list of strings.
  static List<String> _parseStringList(String input) {
    final result = <String>[];
    for (final match
        in RegExp(r"""['"]([^'"]*)['"]""").allMatches(input)) {
      result.add(match.group(1)!);
    }
    return result;
  }
}
