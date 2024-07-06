import 'dart:async';

import 'package:flutter/material.dart';

import 'basic_example.dart' as basic_example;
import 'local_example.dart' as locale_example;
import 'namespace_example.dart' as namespace_example;
import 'network_example.dart' as network_example;

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: Scaffold(
            appBar: AppBar(title: const Text("Flutter i18n")),
            body: Builder(builder: (BuildContext context) {
              return Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    key: const Key('basicExample'),
                    onPressed: () {
                      basic_example.main();
                    },
                    child: const Text("Run `basic` example"),
                  ),
                  ElevatedButton(
                    key: const Key('networkExample'),
                    onPressed: () {
                      network_example.main();
                    },
                    child: const Text("Run `network` example"),
                  ),
                  ElevatedButton(
                    key: const Key('nameSpaceExample'),
                    onPressed: () {
                      namespace_example.main();
                    },
                    child: const Text("Run `namespace` example"),
                  ),
                  ElevatedButton(
                    key: const Key('localeExample'),
                    onPressed: () {
                      locale_example.main();
                    },
                    child: const Text("Run `locale` example"),
                  )
                ],
              ));
            })));
  }
}
