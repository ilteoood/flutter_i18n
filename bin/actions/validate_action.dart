import 'dart:io';

import 'package:flutter_i18n/utils/message_printer.dart';

import 'action_interface.dart';
import '../utils/LocalLoader.dart';

class ValidateAction extends AbstractAction {
  @override
  void executeAction(final List<String> params) async {
    final List<FileSystemEntity> assetsContent = await retrieveAssetsContent();
    assetsContent.forEach(validateFile);
  }

  void validateFile(final FileSystemEntity fileSystemEntity) async {
    MessagePrinter.debug("I've found ${fileSystemEntity.path}");
    final Map? content = await LocalLoader(fileSystemEntity).loadContent();
    validateMap(fileSystemEntity, content);
  }

  void validateMap(
      final FileSystemEntity fileSystemEntity, final Map? content) {
    if (content == null) {
      MessagePrinter.error("Invalid file: ${fileSystemEntity.path}");
    } else {
      MessagePrinter.info("Valid file: ${fileSystemEntity.path}");
    }
  }
}
