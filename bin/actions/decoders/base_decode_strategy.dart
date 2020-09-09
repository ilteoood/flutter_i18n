import 'dart:io';

abstract class BaseDecodeStrategy {
  String get fileExtension;

  get decodeFunction;

  Future<Map> decode(final FileSystemEntity fileSystemEntity) async {
    Map returnValue;
    try {
      final String content = await loadFileContent(fileSystemEntity);
      returnValue = decodeContent(content);
    } catch (e) {
      returnValue = null;
    }
    return returnValue;
  }

  Future<String> loadFileContent(final FileSystemEntity fileSystemEntity) {
    return File(fileSystemEntity.path).readAsString();
  }

  Map decodeContent(final String content) {
    return decodeFunction(content);
  }
}
