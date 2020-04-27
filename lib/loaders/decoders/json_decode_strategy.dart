import 'dart:convert';

import './base_decode_strategy.dart';

class JsonDecodeStrategy extends BaseDecodeStrategy {
  @override
  get fileExtension => "json";

  @override
  get decodeFunction => json.decode;
}
