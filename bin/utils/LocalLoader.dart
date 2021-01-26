import 'dart:io';

import 'package:flutter_i18n/loaders/decoders/base_decode_strategy.dart';
import 'package:flutter_i18n/loaders/decoders/json_decode_strategy.dart';
import 'package:flutter_i18n/loaders/decoders/xml_decode_strategy.dart';
import 'package:flutter_i18n/loaders/decoders/yaml_decode_strategy.dart';
import 'package:flutter_i18n/loaders/file_content.dart';
import 'package:path/path.dart';

class LocalLoader implements IFileContent {
  final FileSystemEntity fileSystemEntity;

  LocalLoader(this.fileSystemEntity);

  @override
  Future<String> loadString(final String fileName, final String extension) {
    return File(this.fileSystemEntity.path).readAsString();
  }

  Future<Map> loadContent() async {
    final BaseDecodeStrategy decodeStrategy = findStrategy(fileSystemEntity);
    return await decodeStrategy.decode(
        basenameWithoutExtension(fileSystemEntity.path), this);
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
