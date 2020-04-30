import 'package:flutter_i18n/loaders/file_content.dart';

import '../../utils/message_printer.dart';

abstract class BaseDecodeStrategy {
  String get fileExtension;

  get decodeFunction;

  Future<Map> decode(
      final String fileName, final IFileContent fileContent) async {
    Map returnValue;
    try {
      final String content = await loadFileContent(fileName, fileContent);
      MessagePrinter.info(
          "${fileExtension.toUpperCase()} file loaded for $fileName");
      returnValue = decodeContent(content);
    } catch (e) {
      MessagePrinter.debug(
          "Unable to load ${fileExtension.toUpperCase()} file for $fileName");
    }
    return returnValue;
  }

  Future<String> loadFileContent(
      final String fileName, final IFileContent fileContent) {
    return fileContent.loadString(fileName, fileExtension);
  }

  Map decodeContent(final String content) {
    return decodeFunction(content);
  }
}
