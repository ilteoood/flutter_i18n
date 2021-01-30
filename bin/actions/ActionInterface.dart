import 'dart:io';

import 'package:yaml/yaml.dart';
import 'package:path/path.dart';

abstract class AbstractAction {

  List<String> get acceptedExtensions => ['.json', '.yaml', '.xml'];

  void executeAction(final List<String> params);

  Future<YamlMap> loadPubspec() async {
    final String pubSpecContent = await File("./pubspec.yaml").readAsString();
    return loadYaml(pubSpecContent);
  }

  Future<List<String>> retrieveAssetsFolders() async {
    final YamlMap pubSec = await loadPubspec();
    final YamlList assetsList = pubSec['flutter']['assets'];
    return assetsList.cast();
  }

  Future<List<FileSystemEntity>> retrieveAssetsContent() async {
    final List<String> assetsFolder = await retrieveAssetsFolders();
    return assetsFolder
        .map((folder) => Directory(folder))
        .where(existFolder)
        .map(folderContent)
        .where((folderContent) => folderContent.isNotEmpty)
        .fold(<FileSystemEntity>[], listFold)
        .where(filterExtension)
        .toList();
  }

  bool existFolder(final Directory directory) {
    return directory.existsSync();
  }

  List<FileSystemEntity> folderContent(final Directory directory) {
    return directory.listSync();
  }

  List<FileSystemEntity> listFold(final List<FileSystemEntity> previousValue,
      final List<FileSystemEntity> currentValue) {
    previousValue.addAll(currentValue);
    return previousValue;
  }

  bool filterExtension(final FileSystemEntity fileSystemEntity) {
    return acceptedExtensions.contains(extension(fileSystemEntity.path));
  }
}
