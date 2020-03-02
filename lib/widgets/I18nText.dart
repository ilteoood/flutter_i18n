import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class I18nText extends StatelessWidget {
  final String _key;
  final Text _child;
  final String fallbackKey;
  final Map<String, String> translationParams;

  const I18nText(this._key, this._child,
      {this.fallbackKey, this.translationParams});

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
