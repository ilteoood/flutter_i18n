import 'package:xml/xml.dart' as xml;

import './base_decode_strategy.dart';

class XmlDecodeStrategy extends BaseDecodeStrategy {
  @override
  get fileExtension => "xml";

  @override
  get decodeFunction => xml.parse;
}
