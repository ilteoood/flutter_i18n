import 'dart:io';

import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

abstract class AbstractAction {
  Set<String> get acceptedExtensions => {'.json', '.yaml', '.xml'};

  void executeAction(final List<String> params);

  Future<dynamic> loadPubspec() async {
    final String pubSpecContent = await File("./pubspec.yaml").readAsString();
    return loadYaml(pubSpecContent);
  }

  Future<List<String>> retrieveAssetsFolders() async {
    dynamic pubSec = await loadPubspec();
    final YamlList yamlList = pubSec['flutter']['assets'];
    return yamlList.cast();
  }

  Future<List<FileSystemEntity>> retrieveAssetsContent() async {
    final List<String> assetEntries = await retrieveAssetsFolders();
    final results = <FileSystemEntity>[];
    for (final entry in assetEntries) {
      final dir = Directory(entry);
      if (dir.existsSync()) {
        results.addAll(dir.listSync().where(filterExtension));
        continue;
      }
      final file = File(entry);
      if (file.existsSync() && filterExtension(file)) {
        results.add(file);
      }
    }
    return results;
  }

  bool filterExtension(final FileSystemEntity fileSystemEntity) {
    return acceptedExtensions.contains(extension(fileSystemEntity.path));
  }
}
