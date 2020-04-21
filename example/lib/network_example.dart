import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_i18n/widgets/I18nText.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class CustomNetworkFileTranslationLoader extends NetworkFileTranslationLoader {
  CustomNetworkFileTranslationLoader({baseUri}) : super(baseUri: baseUri);

  Future<String> loadString(final String fileName, final String extension) {
    return networkAssetBundle.loadString("");
  }
}

Future main() async {
  final FlutterI18nDelegate flutterI18nDelegate = FlutterI18nDelegate(
    translationLoader: CustomNetworkFileTranslationLoader(
      baseUri: Uri.https("postman-echo.com", "get",
          {"title": "Basic network example", "content": "Translated content"}),
    ),
  );

  WidgetsFlutterBinding.ensureInitialized();
  await flutterI18nDelegate.load(null);
  runApp(MyApp(flutterI18nDelegate));
}

class MyApp extends StatelessWidget {
  final FlutterI18nDelegate flutterI18nDelegate;

  MyApp(this.flutterI18nDelegate);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: MyHomePage(),
      localizationsDelegates: [
        flutterI18nDelegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(FlutterI18n.translate(context, "args.title"))),
      body: Builder(builder: (BuildContext context) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              I18nText("args.content"),
            ],
          ),
        );
      }),
    );
  }
}
