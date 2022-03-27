import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import './test_loader.dart';

FlutterI18n? instance;

class TestWidgetNoContext extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final FlutterI18nDelegate flutterI18nDelegate = FlutterI18nDelegate(
      translationLoader: TestJsonLoader(
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
        home: TestWidgetNoContextPage(),
        builder: (context, child) {
          instance = FlutterI18n.of(context);
          return child!;
        },
    );
  }
}

class TestWidgetNoContextPage extends StatefulWidget {
  @override
  createState() => TestWidgetNoContextPageState();
}

class TestWidgetNoContextPageState extends State<TestWidgetNoContextPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Test"),
        ),
        body: Builder(builder: (context) {
          return Center(
            child: Column(
              children: <Widget>[
                I18nText("keySingle", instance: instance),
                I18nPlural("keyPlural", 1, child: Text(""), instance: instance),
                I18nPlural("keyPlural", 2, instance: instance),
                I18nText("object.key1", instance: instance),
                I18nText("object", instance: instance),
                I18nText("object", fallbackKey: "fileName", instance: instance),
                ElevatedButton(
                  onPressed: () async {
                    var locale = FlutterI18n.currentLocale(context, instance: instance);
                    await FlutterI18n.refresh(context, locale, instance: instance);
                  }, child: null,
                ),
              ],
            ),
          );
        }));
  }
}
