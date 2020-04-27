import 'package:yaml/yaml.dart';

import './base_decode_strategy.dart';

class YamlDecodeStrategy extends BaseDecodeStrategy {
  @override
  get fileExtension => "yaml";

  @override
  get decodeFunction => loadYaml;
}
