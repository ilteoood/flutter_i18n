import 'dart:async';

import 'package:flutter/material.dart';

import 'basic_example.dart' as basicExample;
import 'namespace_example.dart' as namespaceExample;
import 'network_example.dart' as networkExample;

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: Scaffold(
            appBar: AppBar(title: Text("Flutter i18n")),
            body: Builder(builder: (BuildContext context) {
              return Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    key: Key('basicExample'),
                    onPressed: () {
                      basicExample.main();
                    },
                    child: Text("Run `basic` example"),
                  ),
                  RaisedButton(
                    key: Key('networkExample'),
                    onPressed: () {
                      networkExample.main();
                    },
                    child: Text("Run `network` example"),
                  ),
                  RaisedButton(
                    onPressed: () {
                      namespaceExample.main();
                    },
                    child: Text("Run `namespace` example"),
                  ),
                ],
              ));
            })));
  }
}
