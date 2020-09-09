import 'dart:io';

import 'package:flutter_i18n/loaders/decoders/base_decode_strategy.dart';
import 'package:flutter_i18n/loaders/decoders/json_decode_strategy.dart';
import 'package:flutter_i18n/loaders/decoders/xml_decode_strategy.dart';
import 'package:flutter_i18n/loaders/decoders/yaml_decode_strategy.dart';
import 'package:flutter_i18n/loaders/file_content.dart';
import 'package:path/path.dart';

import './ActionInterface.dart';

class ValidateAction extends ActionInterface implements IFileContent {

  @override
  void executeAction() async {
    final List<String> assetsFolder = await retrieveAssetsFolders();
    assetsFolder
        .map((folder) => Directory(folder))
        .where(existFolder)
        .map(folderContent)
        .where((folderContent) => folderContent.isNotEmpty)
        .fold(List<FileSystemEntity>(), listFold)
        .where(filterExtension)
        .forEach(validateFile);
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

  void validateFile(final FileSystemEntity fileSystemEntity) {
    final String fileExtension = extension(fileSystemEntity.path);
    final BaseDecodeStrategy decodeStrategy = findStrategy(fileExtension);
    decodeStrategy.decode(fileSystemEntity.path, this);
  }

  @override
  Future<String> loadString(final String fileName, final String extension) {
    return File('$fileName').readAsString();
  }

  findStrategy(final String fileExtension) {
    switch (fileExtension) {
      case "yaml":
        return YamlDecodeStrategy();
      case "xml":
        return XmlDecodeStrategy();
      case "json":
        return JsonDecodeStrategy();
      default:
        throw Exception("Absent strategy for $fileExtension");
    }
  }
}
