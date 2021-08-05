import 'package:toml/toml.dart';

import './base_decode_strategy.dart';

/// Decode strategy for TOML files
class TomlDecodeStrategy extends BaseDecodeStrategy {
  /// The extension of a TOML file
  @override
  get fileExtension => "toml";

  /// The method used to load the TOML file
  @override
  get decodeFunction => (c) => TomlDocument.parse(c).toMap();
}
