import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_i18n/loaders/decoders/json_decode_strategy.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class CustomNetworkFileTranslationLoader extends NetworkFileTranslationLoader {
  CustomNetworkFileTranslationLoader(Uri baseUri)
      : super(baseUri: baseUri, decodeStrategies: [JsonDecodeStrategy()]);

  @override
  Uri resolveUri(final String fileName, final String extension) {
    return baseUri;
  }
}

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FlutterI18nDelegate flutterI18nDelegate = FlutterI18nDelegate(
    translationLoader: CustomNetworkFileTranslationLoader(
      Uri.https("postman-echo.com", "get",
          {"title": "Basic network example", "content": "Translated content"}),
    ),
  );

  runApp(MyApp(flutterI18nDelegate));
}

class MyApp extends StatelessWidget {
  final FlutterI18nDelegate flutterI18nDelegate;

  const MyApp(this.flutterI18nDelegate, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: const MyHomePage(),
      localizationsDelegates: [
        flutterI18nDelegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(FlutterI18n.translate(context, "args.title"))),
      body: Builder(builder: (BuildContext context) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              StreamBuilder<bool>(
                stream: FlutterI18n.retrieveLoadedStream(context),
                builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                  return Text("isLoading: ${snapshot.data}");
                },
              ),
              I18nText(
                "args.content",
                child: const Text(""),
              ),
            ],
          ),
        );
      }),
    );
  }
}
