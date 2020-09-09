import 'dart:io';

import '../utils/message_printer.dart';
import './decoders/base_decode_strategy.dart';
import './decoders/json_decode_strategy.dart';
import './decoders/xml_decode_strategy.dart';
import './decoders/yaml_decode_strategy.dart';
import 'package:path/path.dart';

import './ActionInterface.dart';

class ValidateAction extends ActionInterface {

  @override
  void executeAction(final List<String> params) async {
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

  void validateFile(final FileSystemEntity fileSystemEntity) async {
    MessagePrinter.debug("I've found ${fileSystemEntity.path}");
    final BaseDecodeStrategy decodeStrategy = findStrategy(fileSystemEntity);
    final Map content = await decodeStrategy.decode(fileSystemEntity);
    validateMap(fileSystemEntity, content);
  }

  void validateMap(final FileSystemEntity fileSystemEntity, final Map content) {
    if(content == null) {
      MessagePrinter.error("Invalid file: ${fileSystemEntity.path}");
    } else {
      MessagePrinter.info("Valid file: ${fileSystemEntity.path}");
    }
  }

  findStrategy(final FileSystemEntity fileSystemEntity) {
    final String fileExtension = extension(fileSystemEntity.path);
    switch (fileExtension) {
      case ".yaml":
        return YamlDecodeStrategy();
      case ".xml":
        return XmlDecodeStrategy();
      case ".json":
        return JsonDecodeStrategy();
      default:
        throw Exception("Absent strategy for $fileExtension");
    }
  }
}
