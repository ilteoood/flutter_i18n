import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n_delegate.dart';
import 'package:flutter_i18n/loaders/decoders/json_decode_strategy.dart';
import 'package:flutter_i18n/loaders/local_translation_loader.dart';
import 'package:flutter_i18n/widgets/I18nText.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final basePath = await findBasePath();
  await downloadTranslationContent(basePath);
  final flutterI18nDelegate = FlutterI18nDelegate(
    translationLoader: LocalTranslationLoader(
      basePath: basePath,
      decodeStrategies: [JsonDecodeStrategy()],
    ),
  );

  runApp(Test(flutterI18nDelegate));
}

Future<String> findBasePath() async {
  final appDocDir = await getApplicationDocumentsDirectory();
  return '${appDocDir.path}/langs';
}

Future downloadTranslationContent(final String basePath) async {
  final file = File('$basePath/en.json');
  final translationContentResponse = await http
      .get('https://opensource.adobe.com/Spry/data/json/object-02.js');
  await file.create(recursive: true);
  await file.writeAsString(translationContentResponse.body, flush: true);
}

class Test extends StatefulWidget {
  Test(this.flutterI18nDelegate);

  final FlutterI18nDelegate flutterI18nDelegate;

  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        widget.flutterI18nDelegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text('Test')),
          body: Column(children: <Widget>[
            Container(
              color: Colors.blue,
              padding: const EdgeInsets.all(40),
              child: I18nText('type'),
            ),
          ]),
        ),
      ),
    );
  }
}
