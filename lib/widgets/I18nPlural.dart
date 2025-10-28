import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

/// Widget for plural text translation
class I18nPlural extends StatelessWidget {
  final String _key;
  final int _pluralValue;
  final Text child;
  static const _default_text = Text("");

  const I18nPlural(this._key, this._pluralValue, {Key? key, this.child = _default_text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      FlutterI18n.plural(context, _key, _pluralValue),
      key: child.key,
      style: child.style,
      strutStyle: child.strutStyle,
      textAlign: child.textAlign,
      textDirection: child.textDirection,
      softWrap: child.softWrap,
      overflow: child.overflow,
      textScaler: child.textScaler,
      maxLines: child.maxLines,
      semanticsLabel: child.semanticsLabel,
      textWidthBasis: child.textWidthBasis,
      textHeightBehavior: child.textHeightBehavior,
    );
  }
}
