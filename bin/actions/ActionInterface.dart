import 'dart:io';

import 'package:yaml/yaml.dart';

abstract class ActionInterface {

  List<String> get acceptedExtensions => ['.json', '.yaml', '.xml'];

  void executeAction(final List<String> params);

  Future<dynamic> loadPubspec() async {
    final String pubSpecContent = await File("./pubspec.yaml").readAsString();
    return loadYaml(pubSpecContent);
  }

  Future<List<String>> retrieveAssetsFolders() async {
    dynamic pubSec = await loadPubspec();
    final YamlList yamlList = pubSec['flutter']['assets'];
    return yamlList.cast();
  }
}
