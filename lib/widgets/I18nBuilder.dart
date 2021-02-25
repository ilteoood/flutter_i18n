import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

typedef FlutterI18nWidgetBuilder = Widget Function(BuildContext context, Locale locale);

class I18nBuilder extends StatelessWidget {
  final FlutterI18n _translationObject;
  final FlutterI18nWidgetBuilder builder;

  I18nBuilder({this.builder, FlutterI18n translationObject, Key key})
      : _translationObject = translationObject,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final translationObject = _translationObject ?? FlutterI18n.of(context);
    return StreamBuilder<Locale>(
        stream: translationObject.localeStream.distinct(),
        builder: (context, snapshot) => builder(context, snapshot.data));
  }
}
