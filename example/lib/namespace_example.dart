import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future main() async {
  final FlutterI18nDelegate flutterI18nDelegate = FlutterI18nDelegate(
    translationLoader: NamespaceFileTranslationLoader(
      namespaces: ["common", "home"],
      useCountryCode: false,
      fallbackDir: 'en',
      basePath: 'assets/i18n_namespace',
      forcedLocale: const Locale('it'),
    ),
    missingTranslationHandler: (key, locale) {
      // ignore: avoid_print
      print("--- Missing Key: $key, languageCode: ${locale!.languageCode}");
    },
  );
  WidgetsFlutterBinding.ensureInitialized();
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
        primarySwatch: Colors.deepPurple,
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomeState createState() => MyHomeState();
}

class MyHomeState extends State<MyHomePage> {
  changeLanguage() async {
    final currentLang = FlutterI18n.currentLocale(context)!;
    final nextLang =
        currentLang.languageCode == 'ua' ? const Locale('en') : const Locale('ua');
    await FlutterI18n.refresh(context, nextLang);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(FlutterI18n.translate(context, "common.title"))),
      body: Builder(builder: (BuildContext context) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const I18nText("home.label.main", child: Text("")),
              const I18nText("home.missing", child: Text("")),
              ElevatedButton(
                  onPressed: () async {
                    await changeLanguage();
                  },
                  child: const Text("Change language"))
            ],
          ),
        );
      }),
    );
  }
}
