import 'package:yaml/yaml.dart';

import './base_decode_strategy.dart';

/// Decode strategy for YAML files
class YamlDecodeStrategy extends BaseDecodeStrategy {

  /// The extension of a YAML file
  @override
  get fileExtension => "yaml";

  /// The method used to load the YAML file
  @override
  get decodeFunction => loadYaml;
}
