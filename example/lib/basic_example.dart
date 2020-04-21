import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_i18n/widgets/I18nText.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future main() async {
  final FlutterI18nDelegate flutterI18nDelegate = FlutterI18nDelegate(
    translationLoader: FileTranslationLoader(
        useCountryCode: false,
        fallbackFile: 'en',
        basePath: 'assets/i18n',
        forcedLocale: Locale('es')),
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
        primarySwatch: Colors.blue,
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

class MyHomePage extends StatefulWidget {
  @override
  MyHomeState createState() => MyHomeState();
}

class MyHomeState extends State<MyHomePage> {
  Locale currentLang;
  int clicked = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      setState(() {
        currentLang = FlutterI18n.currentLocale(context);
      });
    });
  }

  changeLanguage() async {
    currentLang =
        currentLang.languageCode == 'en' ? Locale('it') : Locale('en');
    await FlutterI18n.refresh(context, currentLang);
    setState(() {});
  }

  incrementCounter() {
    setState(() {
      clicked++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(FlutterI18n.translate(context, "title"))),
      body: Builder(builder: (BuildContext context) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              I18nText("label.main",
                  translationParams: {"user": "Flutter lover"}),
              I18nText.plural("clicked.times", clicked),
              FlatButton(
                  onPressed: () async {
                    incrementCounter();
                  },
                  child: Text(FlutterI18n.translate(
                      context, "button.label.clickMea",
                      fallbackKey: "button.label.clickMe"))),
              FlatButton(
                  onPressed: () async {
                    await changeLanguage();
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text(FlutterI18n.translate(
                          context, "button.toastMessage")),
                    ));
                  },
                  child: Text(
                      FlutterI18n.translate(context, "button.label.language")))
            ],
          ),
        );
      }),
    );
  }
}
