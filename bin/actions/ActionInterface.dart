import 'dart:io';

import 'package:yaml/yaml.dart';

abstract class ActionInterface {

  List<String> get acceptedExtensions => ['json', 'yaml', 'xml'];

  void executeAction();

  Future<dynamic> loadPubspec() async {
    final String pubSpecContent = await File("./pubspec.yaml").readAsString();
    return loadYaml(pubSpecContent);
  }

  Future<List<String>> retrieveAssetsFolders() async {
    dynamic pubSec = await loadPubspec();
    return pubSec['flutter']['assets'];
  }
}
