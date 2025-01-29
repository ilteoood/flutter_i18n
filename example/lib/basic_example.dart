import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future main() async {
  final FlutterI18nDelegate flutterI18nDelegate = FlutterI18nDelegate(
    translationLoader: FileTranslationLoader(
        useCountryCode: false,
        fallbackFile: 'en',
        basePath: 'assets/i18n',
        forcedLocale: const Locale('es')),
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
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
      localizationsDelegates: [
        flutterI18nDelegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      builder: FlutterI18n.rootAppBuilder(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomeState createState() => MyHomeState();
}

class MyHomeState extends State<MyHomePage> {
  int clicked = 0;

  incrementCounter() {
    setState(() {
      clicked++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(FlutterI18n.translate(context, "title"))),
      body: Builder(
        builder: (BuildContext context) => StreamBuilder<bool>(
          initialData: true,
          stream: FlutterI18n.retrieveLoadedStream(context),
          builder: (BuildContext context, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                I18nText("label.main",
                    translationParams: const {"user": "Flutter lover"}),
                I18nPlural("clicked.times", clicked),
                TextButton(
                    key: const Key('incrementCounter'),
                    onPressed: () async {
                      incrementCounter();
                    },
                    child: Text(FlutterI18n.translate(
                        context, "button.label.clickMea",
                        fallbackKey: "button.label.clickMe"))),
                TextButton(
                    key: const Key('changeLanguage'),
                    onPressed: () async {
                      final Locale? currentLang =
                          FlutterI18n.currentLocale(context);
                      await FlutterI18n.refresh(
                          context,
                          currentLang!.languageCode == 'en'
                              ? const Locale('it')
                              : const Locale('en'));

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(FlutterI18n.translate(
                              context, "button.toastMessage")),
                        ));
                      }
                    },
                    child: Text(FlutterI18n.translate(
                        context, "button.label.language")))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
