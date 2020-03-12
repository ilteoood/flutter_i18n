import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import './test_loader.dart';

class TestWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final FlutterI18nDelegate flutterI18nDelegate = FlutterI18nDelegate(
      translationLoader: TestLoader(
          useCountryCode: false,
          fallbackFile: 'en',
          basePath: 'assets/i18n',
          forcedLocale: Locale('en')),
    );

    return MaterialApp(
        title: 'Flutter Demo',
        localizationsDelegates: [
          flutterI18nDelegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
        home: Scaffold(
            appBar: AppBar(
              title: Text("Test"),
            ),
            body: Builder(builder: (context) {
              return Center(
                child: Column(
                  children: <Widget>[
                    I18nText("keySingle", Text("")),
                    I18nPlural("keyPlural", 1, Text("")),
                    I18nPlural("keyPlural", 2, Text("")),
                  ],
                ),
              );
            })));
  }
}
