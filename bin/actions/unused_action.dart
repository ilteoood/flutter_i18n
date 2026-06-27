import 'dart:io';

import 'package:flutter_i18n/utils/message_printer.dart';
import 'package:path/path.dart' as p;

import '../utils/key_extractor.dart';
import '../utils/local_loader.dart';
import '../utils/source_scanner.dart';
import 'action_interface.dart';

class UnusedAction extends AbstractAction {
  bool _md = false;
  String _mdPath = 'unused_translations.md';
  List<String> _scanPaths = [];

  @override
  List<String> get acceptedExtensions => ['.json', '.yaml', '.xml', '.toml'];

  @override
  void executeAction(final List<String> params) async {
    _parseArgs(params);

    final scanResult = SourceScanner.scan(
      Directory.current.path,
      scanPaths: _scanPaths.isNotEmpty ? _scanPaths : null,
    );

    final assetKeys = await _collectAssetKeys(scanResult.namespaceConfigs);

    // Build matchable set and compute unused keys in a single pass.
    final matchableAssets = <String>{...assetKeys};
    final unused = <String>{};
    for (final key in assetKeys) {
      final norm = KeyExtractor.normalizePlural(key);
      if (norm != null) matchableAssets.add(norm);

      if (!scanResult.literalKeys.contains(key) &&
          (norm == null || !scanResult.literalKeys.contains(norm))) {
        unused.add(key);
      }
    }

    // Missing: source keys not found in any translation file.
    final missing = <String>{};
    for (final key in scanResult.literalKeys) {
      if (!matchableAssets.contains(key)) {
        missing.add(key);
      }
    }

    _report(unused, missing, scanResult.dynamicRefs);
  }

  void _parseArgs(List<String> params) {
    for (final param in params) {
      if (param == '--md') {
        _md = true;
      } else if (param.startsWith('--path=')) {
        final v = param.substring('--path='.length);
        if (v.isEmpty) {
          MessagePrinter.error('--path requires a value (e.g. --path=report.md)');
        } else {
          _mdPath = v;
        }
      } else if (param.startsWith('--scan=')) {
        _scanPaths = param
            .substring('--scan='.length)
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }
    }
  }

  /// Walk every asset folder declared in pubspec and extract translation keys.
  ///
  /// If [namespaceConfigs] (extracted from source code) is non-empty, uses
  /// the declared namespaces and basePath directly.  Falls back to
  /// directory-structure heuristics otherwise.
  Future<Set<String>> _collectAssetKeys(
      List<NamespaceConfig> namespaceConfigs) async {
    final keys = <String>{};

    // Use explicit namespace config from source code.
    for (final config in namespaceConfigs) {
      if (config.isNamespace && config.basePath != null) {
        await _loadFromNamespaceConfig(config, keys);
      }
    }

    final nsBasePaths = namespaceConfigs
        .where((c) => c.basePath != null)
        .map((c) => p.normalize(c.basePath!))
        .toSet();

    final assetFolders = await retrieveAssetsFolders();
    for (final folder in assetFolders) {
      final dir = Directory(folder);
      if (dir.existsSync()) {
        // Skip folders already covered by a namespace basePath.
        final norm = p.normalize(folder);
        if (nsBasePaths.any((bp) =>
            norm == bp || norm.startsWith('$bp${p.separator}'))) {
          continue;
        }

        final children = dir.listSync();
        if (children.any((c) => c is Directory)) {
          // Namespace A: folder contains locale-code subdirectories.
          for (final child in children) {
            if (child is Directory) {
              await _addNamespaceDir(child, keys);
            }
          }
        } else if (namespaceConfigs.isEmpty &&
            _isNamespaceLocaleDir(folder, assetFolders)) {
          // Namespace B: locale dir listed individually, no config found.
          await _addNamespaceDir(dir, keys);
        } else {
          await _addFlatDir(dir, keys);
        }
        continue;
      }

      // Individual files listed directly in assets.
      final file = File(folder);
      if (file.existsSync() &&
          acceptedExtensions.contains(p.extension(folder))) {
        final map = await LocalLoader(file).loadContent();
        if (map != null) keys.addAll(KeyExtractor.extract(map));
      }
    }

    return keys;
  }

  /// True when [folder] is one of multiple locale directories sharing a
  /// common parent.
  bool _isNamespaceLocaleDir(String folder, List<String> allFolders) {
    final parent = p.dirname(folder);
    return allFolders.where((f) => p.dirname(f) == parent).length > 1;
  }

  /// Load translation files using the explicit namespace config.
  Future<void> _loadFromNamespaceConfig(
      NamespaceConfig config, Set<String> keys) async {
    final base = Directory(config.basePath!);
    if (!base.existsSync()) return;

    for (final localeDir in base.listSync()) {
      if (localeDir is! Directory) continue;
      for (final namespace in config.namespaces) {
        for (final entity in localeDir.listSync()) {
          if (entity is! File) continue;
          if (p.basenameWithoutExtension(p.basename(entity.path)) !=
              namespace) {
            continue;
          }
          if (!acceptedExtensions.contains(p.extension(entity.path))) {
            continue;
          }

          final map = await LocalLoader(entity).loadContent();
          if (map == null) continue;
          for (final key in KeyExtractor.extract(map)) {
            keys.add('$namespace.$key');
          }
        }
      }
    }
  }

  Future<void> _addNamespaceDir(Directory dir, Set<String> keys) async {
    for (final entity in dir.listSync()) {
      if (entity is File &&
          acceptedExtensions.contains(p.extension(entity.path))) {
        final map = await LocalLoader(entity).loadContent();
        if (map == null) continue;
        final ns = p.basenameWithoutExtension(p.basename(entity.path));
        for (final key in KeyExtractor.extract(map)) {
          keys.add('$ns.$key');
        }
      }
    }
  }

  Future<void> _addFlatDir(Directory dir, Set<String> keys) async {
    for (final entity in dir.listSync()) {
      if (entity is File &&
          acceptedExtensions.contains(p.extension(entity.path))) {
        final map = await LocalLoader(entity).loadContent();
        if (map == null) continue;
        keys.addAll(KeyExtractor.extract(map));
      }
    }
  }

  void _report(
    Set<String> unused,
    Set<String> missing,
    List<DynamicKeyRef> dynamicRefs,
  ) {
    final sortedUnused = unused.toList()..sort();
    final sortedMissing = missing.toList()..sort();

    if (!_md) {
      // Terminal output.
      _printSection('Unused translation keys', sortedUnused,
          'Defined in translation files but never referenced in source code');
      _printSection('Missing translation keys', sortedMissing,
          'Referenced in source code but not found in translation files');
      _printDynamicSection(dynamicRefs);
    } else {
      // Markdown file output.
      final buf = StringBuffer();
      buf.writeln('# Unused Translation Report');
      buf.writeln();

      _writeMdSection(buf, 'Unused translation keys', sortedUnused,
          'Defined in translation files but never referenced in source code');
      _writeMdSection(buf, 'Missing translation keys', sortedMissing,
          'Referenced in source code but not found in translation files');
      _writeMdDynamicSection(buf, dynamicRefs);

      File(_mdPath).writeAsStringSync(buf.toString());
      MessagePrinter.info('Report written to $_mdPath');
    }
  }

  void _printSection(String title, List<String> keys, String description) {
    MessagePrinter.info('');
    MessagePrinter.info('=== $title ===');
    MessagePrinter.info(description);
    MessagePrinter.info('Total: ${keys.length}');
    MessagePrinter.info('');
    if (keys.isEmpty) {
      MessagePrinter.info('  None');
    } else {
      var n = 1;
      for (final key in keys) {
        MessagePrinter.info('  $n. $key');
        n++;
      }
    }
  }

  void _printDynamicSection(List<DynamicKeyRef> refs) {
    MessagePrinter.info('');
    MessagePrinter.info('=== Dynamic keys ===');
    MessagePrinter.info(
        'Keys constructed with variables or expressions — cannot analyze statically');
    MessagePrinter.info('Total: ${refs.length}');
    MessagePrinter.info('');
    if (refs.isEmpty) {
      MessagePrinter.info('  None');
    } else {
      var n = 1;
      for (final ref in refs) {
        final rel = p.relative(ref.filePath, from: Directory.current.path);
        MessagePrinter.info('  $n. $rel:${ref.line}');
        for (final line in ref.lineContent.split('\n')) {
          MessagePrinter.info('    $line');
        }
        n++;
      }
    }
    MessagePrinter.info('');
  }

  void _writeMdSection(
      StringBuffer buf, String title, List<String> keys, String description) {
    buf.writeln('## $title');
    buf.writeln();
    buf.writeln('$description  ');
    buf.writeln('**Total: ${keys.length}**  ');
    buf.writeln();
    if (keys.isEmpty) {
      buf.writeln('*None*');
    } else {
      var n = 1;
      for (final key in keys) {
        buf.writeln('$n. `$key`');
        n++;
      }
    }
    buf.writeln();
  }

  void _writeMdDynamicSection(StringBuffer buf, List<DynamicKeyRef> refs) {
    buf.writeln('## Dynamic keys (manual review needed)');
    buf.writeln();
    buf.writeln(
        'Keys constructed with variables or expressions — cannot analyze statically.  ');
    buf.writeln('**Total: ${refs.length}**  ');
    buf.writeln();
    if (refs.isEmpty) {
      buf.writeln('*None*');
    } else {
      var n = 1;
      for (final ref in refs) {
        final rel = p.relative(ref.filePath, from: Directory.current.path);
        buf.writeln('$n. **[$rel:${ref.line}]($rel#L${ref.line})**');
        buf.writeln();
        buf.writeln('  ```dart');
        for (final line in ref.lineContent.split('\n')) {
          buf.writeln('  $line');
        }
        buf.writeln('  ```');
        buf.writeln();
        n++;
      }
    }
    buf.writeln();
  }
}
