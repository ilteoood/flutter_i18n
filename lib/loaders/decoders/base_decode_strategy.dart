import '../translation_loader.dart';
import '../../utils/message_printer.dart';

abstract class BaseDecodeStrategy {
  String get fileExtension;

  get decodeFunction;

  Future<Map> decode(
      final String fileName, final TranslationLoader translationLoader) async {
    Map returnValue;
    try {
      final String fileContent =
          await loadFileContent(fileName, translationLoader);
      MessagePrinter.info(
          "${fileExtension.toUpperCase()} file loaded for $fileName");
      returnValue = decodeFunction(fileContent);
    } catch (e) {
      MessagePrinter.debug(
          "Unable to load ${fileExtension.toUpperCase()} file for $fileName");
    }
    return returnValue;
  }

  Future<String> loadFileContent(
      final String fileName, final TranslationLoader translationLoader) async {
    return await translationLoader.loadString(fileName, fileExtension);
  }
}
