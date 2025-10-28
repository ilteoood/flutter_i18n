import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

/// Widget for simple text translation
class I18nText extends StatelessWidget {
  final String _key;
  final Text child;
  final String? fallbackKey;
  final Map<String, String>? translationParams;
  static const _defaultText = Text("");

  const I18nText(this._key,
      {Key? key, this.child = _defaultText, this.fallbackKey, this.translationParams}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      FlutterI18n.translate(context, _key,
          fallbackKey: fallbackKey, translationParams: translationParams),
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
