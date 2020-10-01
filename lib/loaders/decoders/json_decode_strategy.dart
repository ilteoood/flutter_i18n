import 'dart:convert';

import './base_decode_strategy.dart';

/// Decode strategy for JSON files
class JsonDecodeStrategy extends BaseDecodeStrategy {

  /// The extension of a JSON file
  @override
  get fileExtension => "json";

  /// The method used to load the JSON file
  @override
  get decodeFunction => json.decode;
}
