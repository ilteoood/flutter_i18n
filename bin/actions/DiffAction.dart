import 'dart:io';

import 'package:flutter_i18n/utils/message_printer.dart';

import '../utils/LocalLoader.dart';
import 'ActionInterface.dart';

class DiffAction extends AbstractAction {
  @override
  void executeAction(final List<String> params) async {
    MessagePrinter.info(params.toString());
    final String baseFile = params[0];
    final String compareFile = params[1];
    final List<FileSystemEntity> assetsContent = await retrieveAssetsContent();
    final Map baseFileContent =
        await retrieveFileContent(assetsContent, baseFile);
    final Map compareFileContent =
        await retrieveFileContent(assetsContent, compareFile);
    mapCompare(baseFileContent, compareFileContent, "");
  }

  mapCompare(final Map baseFileContent, final Map compareFileContent,
      final String keyPrefix) {
    final Set keysSet = Set.from(baseFileContent.keys);
    keysSet.addAll(compareFileContent.keys);
    keysSet.forEach((dictKey) {
      if(!baseFileContent.containsKey(dictKey)) {
        MessagePrinter.error("The base dictionary doesn't contain the key $keyPrefix>$dictKey");
      } else {
        final dictContent = baseFileContent[dictKey];
        if(dictContent is String) {

        }
      }
      if(!compareFileContent.containsKey(dictKey)) {
        MessagePrinter.error("The compared dictionary doesn't contain the key $keyPrefix.$dictKey");
      }
    });
  }

  Future<Map> retrieveFileContent(
      final List<FileSystemEntity> assetsContent, final String fileToRetrieve) {
    final FileSystemEntity fileSystemEntity =
        retrieveEntity(assetsContent, fileToRetrieve);
    return LocalLoader(fileSystemEntity).loadContent();
  }

  FileSystemEntity retrieveEntity(
      final List<FileSystemEntity> assetsContent, final String fileToRetrieve) {
    final List<FileSystemEntity> possibleFiles = assetsContent
        .where((fileSystemEntity) =>
            fileSystemEntity.path.endsWith(fileToRetrieve))
        .toList();
    checkFileList(possibleFiles, fileToRetrieve);
    return possibleFiles.first;
  }

  void checkDiff(final Map diffMap) {
    MessagePrinter.info("Calculated diff: ${diffMap.toString()}");
  }

  void checkFileList(
      final List<FileSystemEntity> possibleFiles, final String fileToRetrieve) {
    if (possibleFiles.isEmpty)
      throw new Exception("Unable to find $fileToRetrieve");
  }
}
