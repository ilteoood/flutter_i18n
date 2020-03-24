import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class I18nText extends StatelessWidget {
  String _key;
  Text _child;
  String fallbackKey;
  Map<String, String> translationParams;

  I18nText(this._key, {child, this.fallbackKey, this.translationParams}) {
    this._child = child ?? Text("");
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      FlutterI18n.translate(context, _key,
          fallbackKey: fallbackKey, translationParams: translationParams),
      key: _child.key,
      style: _child.style,
      strutStyle: _child.strutStyle,
      textAlign: _child.textAlign,
      textDirection: _child.textDirection,
      softWrap: _child.softWrap,
      overflow: _child.overflow,
      textScaleFactor: _child.textScaleFactor,
      maxLines: _child.maxLines,
      semanticsLabel: _child.semanticsLabel,
      textWidthBasis: _child.textWidthBasis,
    );
  }
}
