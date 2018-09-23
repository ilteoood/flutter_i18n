import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_i18n/flutter_i18n_delegate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
      localizationsDelegates: [
        FlutterI18nDelegate(false, 'en'),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar:
          new AppBar(title: new Text(FlutterI18n.translate(context, "title"))),
      body: new Builder(builder: (BuildContext context) {
        return new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(FlutterI18n.translate(context, "label.main",  Map.fromIterables(["user"], ["Flutter lover"]))),
              new FlatButton(
                  onPressed: () {
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
