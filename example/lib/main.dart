import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_i18n/flutter_i18n_delegate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future main() async {
  FlutterI18n flutterI18n=FlutterI18n(false,"",'assets/i18n');
   await flutterI18n.load();
  runApp(new MyApp(flutterI18n: flutterI18n,));
}

class MyApp extends StatelessWidget {
  final FlutterI18n flutterI18n;
  MyApp({this.flutterI18n});
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
      localizationsDelegates: [
        FlutterI18nDelegate(flutterI18n: flutterI18n),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  MyHomeState createState() => new MyHomeState();
}

class MyHomeState extends State<MyHomePage> {
  Locale currentLang;
  int clicked = 0;

  changeLanguage() {
    setState(() {
      currentLang =
          currentLang.languageCode == 'en' ? new Locale('it') : new Locale('en');
    });
  }

  incrementCounter() {
    setState(() {
      clicked++;
    });
  }

  @override
  Widget build(BuildContext context) {
    currentLang = FlutterI18n.currentLocale(context);
    return new Scaffold(
      appBar:
          new AppBar(title: new Text(FlutterI18n.translate(context, "title"))),
      body: new Builder(builder: (BuildContext context) {
        return new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(FlutterI18n.translate(context, "label.main",
                  Map.fromIterables(["user"], ["Flutter lover"]))),
              new Text(FlutterI18n.plural(context, "clicked.times", clicked)),
              new FlatButton(
                  onPressed: () async {
                    incrementCounter();
                  },
                  child: new Text(
                      FlutterI18n.translate(context, "button.clickMe"))),
              new FlatButton(
                  onPressed: () async {
                    changeLanguage();
                    await FlutterI18n.refresh(context, currentLang);
                    Scaffold.of(context).showSnackBar(new SnackBar(
                      content: new Text(
                          FlutterI18n.translate(context, "toastMessage")),
                    ));
                  },
                  child: new Text(
                      FlutterI18n.translate(context, "button.clickMe")))
            ],
          ),
        );
      }),
    );
  }
}
