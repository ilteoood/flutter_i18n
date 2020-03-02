import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class I18nPlural extends StatelessWidget {
  final String _key;
  final Text _child;
  final int _pluralValue;

  const I18nPlural(this._key, this._pluralValue, this._child);

  @override
  Widget build(BuildContext context) {
    return Text(
      FlutterI18n.plural(context, _key, _pluralValue),
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
